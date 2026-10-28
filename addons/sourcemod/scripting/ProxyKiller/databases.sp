// =========================================================== //
// Enums and Globals
// =========================================================== //

static char DB_CONF_NAME[] = "ProxyKiller";

enum DatabaseState
{
	DatabaseState_Disconnected = 0,
	DatabaseState_Wait,
	DatabaseState_Connecting,
	DatabaseState_Connected,
}

enum DatabaseType
{
	DBType_MySQL,
	DBType_SQLite
}

DatabaseState g_DatabaseStates[4];
Database g_hDatabases[4];
int g_iConnectLocks[4];
int g_iSequences[4];
bool g_bDbInitialized[4];

// Database indices for easy access
#define Idx_ProxyCacheMySQL 0
#define Idx_ProxyCacheSQLite 1
#define Idx_ProxyRulesMySQL 2
#define Idx_ProxyRulesSQLite 3

// Database.Connect() only carries a single data cell, so DB_Connect packs the
// slot index (low bits) and the connect-attempt sequence number (the rest)
// into it, and DB_GotDatabase unpacks both.
#define DB_DATA_INDEX_BITS 8
#define DB_DATA_INDEX_MASK ((1 << DB_DATA_INDEX_BITS) - 1)

// Delay before retrying after a lost or failed connection
#define DB_RETRY_DELAY 10.0

// A client check that finds its database not connected is retried this often,
// up to this many times, instead of being dropped
#define DB_CHECK_RETRY_DELAY 5.0
#define DB_CHECK_RETRY_MAX 12

// =========================================================== //
// Generic Database Connection Logic
// =========================================================== //

public bool DB_Connect(int dbIndex, DatabaseType dbType, const char[] dbName)
{
	if (g_hDatabases[dbIndex] != null && g_DatabaseStates[dbIndex] == DatabaseState_Connected)
		return true;

	// Avoid excessive connection attempts
	if (g_DatabaseStates[dbIndex] == DatabaseState_Wait)
		return false;

	if (g_DatabaseStates[dbIndex] != DatabaseState_Connecting)
	{
		if (!SQL_CheckConfig(dbName))
			SetFailState("Could not find \"%s\" entry in databases.cfg.", dbName);

		g_DatabaseStates[dbIndex] = DatabaseState_Connecting;
		g_iConnectLocks[dbIndex] = g_iSequences[dbIndex]++;
		Database.Connect(DB_GotDatabase, dbName, (g_iConnectLocks[dbIndex] << DB_DATA_INDEX_BITS) | dbIndex);
	}

	return false;
}

public void DB_GotDatabase(Database db, const char[] error, any data)
{
	int dbIndex = data & DB_DATA_INDEX_MASK;
	int sequence = data >> DB_DATA_INDEX_BITS;

	if (db == null)
	{
		// Only the current attempt may schedule the retry: a stale failure must
		// not touch the state of a slot that a newer attempt now owns.
		if (g_DatabaseStates[dbIndex] == DatabaseState_Connecting && g_iConnectLocks[dbIndex] == sequence)
		{
			LogError("Connecting to database failed: %s. Retry after delay of %0.f seconds.", error, DB_RETRY_DELAY);
			DB_ScheduleReconnect(dbIndex);
		}
		else
		{
			LogError("Connecting to database failed: %s", error);
		}
		return;
	}

	char sType[32];
	switch (dbIndex)
	{
		case Idx_ProxyCacheMySQL:
			FormatEx(sType, sizeof(sType), "Cache (MySQL)");
		case Idx_ProxyRulesMySQL:
			FormatEx(sType, sizeof(sType), "Rules (MySQL)");
		case Idx_ProxyCacheSQLite:
			FormatEx(sType, sizeof(sType), "Cache (SQLite)");
		case Idx_ProxyRulesSQLite:
			FormatEx(sType, sizeof(sType), "Rules (SQLite)");
		default:
			FormatEx(sType, sizeof(sType), "Unknown");
	}
	LogMessage("<ProxyKiller-%s> Connected to database.", sType);

	// If it's an old connection request, ignore it
	if (g_iConnectLocks[dbIndex] != sequence || (g_hDatabases[dbIndex] != null && g_DatabaseStates[dbIndex] == DatabaseState_Connected))
	{
		if (db)
			delete db;
		return;
	}

	char sDriver[16];
	db.Driver.GetIdentifier(sDriver, sizeof(sDriver));

	if ((dbIndex == Idx_ProxyCacheMySQL || dbIndex == Idx_ProxyRulesMySQL) && !StrEqual(sDriver, "mysql", false))
	{
		SetFailState("Invalid database driver for MySQL, expecting \"mysql\"");
	}
	else if ((dbIndex == Idx_ProxyCacheSQLite || dbIndex == Idx_ProxyRulesSQLite) && !StrEqual(sDriver, "sqlite", false))
	{
		SetFailState("Invalid database driver for SQLite, expecting \"sqlite\"");
	}

	g_iConnectLocks[dbIndex] = 0;
	g_DatabaseStates[dbIndex] = DatabaseState_Connected;
	g_hDatabases[dbIndex] = db;

	// The provider handle is only known once the async connection succeeds,
	// so wire it into the matching Cache/Rules object here and run its
	// one-time schema setup instead of doing it eagerly at creation time.
	switch (dbIndex)
	{
		case Idx_ProxyCacheMySQL:
		{
			if (g_Cache != null)
			{
				g_Cache.Provider = db;
				if (!g_bDbInitialized[dbIndex])
				{
					view_as<ProxyCacheMySQL>(g_Cache).Initialize();
					g_bDbInitialized[dbIndex] = true;
				}
			}
		}
		case Idx_ProxyCacheSQLite:
		{
			if (g_Cache != null)
			{
				g_Cache.Provider = db;
				if (!g_bDbInitialized[dbIndex])
				{
					view_as<ProxyCacheSQLite>(g_Cache).Initialize();
					g_bDbInitialized[dbIndex] = true;
				}
			}
		}
		case Idx_ProxyRulesMySQL:
		{
			if (g_Rules != null)
			{
				g_Rules.Provider = db;
				if (!g_bDbInitialized[dbIndex])
				{
					view_as<ProxyRulesMySQL>(g_Rules).Initialize();
					g_bDbInitialized[dbIndex] = true;
				}
			}
		}
		case Idx_ProxyRulesSQLite:
		{
			if (g_Rules != null)
			{
				g_Rules.Provider = db;
				if (!g_bDbInitialized[dbIndex])
				{
					view_as<ProxyRulesSQLite>(g_Rules).Initialize();
					g_bDbInitialized[dbIndex] = true;
				}
			}
		}
	}
}

public bool DB_IsConnectionError(const char[] error)
{
	return StrContains(error, "Lost connection", false) != -1
		|| StrContains(error, "gone away", false) != -1
		|| StrContains(error, "Can't connect", false) != -1
		|| StrContains(error, "Broken pipe", false) != -1;
}

public bool DB_Conn_Lost(int dbIndex, DBResultSet results, const char[] error)
{
	// Only a real connection failure invalidates the handle: a plain SQL
	// error (syntax, constraint, ...) must not tear the connection down.
	if (results == null && DB_IsConnectionError(error))
	{
		if (g_hDatabases[dbIndex] != null)
		{
			LogError("Lost connection to DB. Reconnect after delay of %0.f seconds.", DB_RETRY_DELAY);
			delete g_hDatabases[dbIndex];
		}

		if (g_DatabaseStates[dbIndex] != DatabaseState_Wait && g_DatabaseStates[dbIndex] != DatabaseState_Connecting)
			DB_ScheduleReconnect(dbIndex);

		return true;
	}

	return false;
}

public void DB_ScheduleReconnect(int dbIndex)
{
	// DB_Connect refuses to start a new attempt while the slot is in Wait, so
	// this timer must survive a map change: TIMER_FLAG_NO_MAPCHANGE would
	// leave the slot stuck in Wait forever.
	g_DatabaseStates[dbIndex] = DatabaseState_Wait;
	CreateTimer(DB_RETRY_DELAY, DB_TimerDB_Reconnect, dbIndex);
}

public Action DB_TimerDB_Reconnect(Handle timer, any data)
{
	int dbIndex = view_as<int>(data);
	DB_Reconnect(dbIndex);
	return Plugin_Continue;
}

public void DB_Reconnect(int dbIndex)
{
	g_DatabaseStates[dbIndex] = DatabaseState_Disconnected;
	if (dbIndex == Idx_ProxyCacheMySQL || dbIndex == Idx_ProxyCacheSQLite)
	{
		DB_Connect(dbIndex, DBType_MySQL, DB_CONF_NAME);
	}
	else
	{
		DB_Connect(dbIndex, DBType_SQLite, DB_CONF_NAME);
	}
}

// =========================================================== //
// Deferred client checks
// =========================================================== //

// Called while the rules/cache database is still connecting or reconnecting:
// keep the ProxyUser and retry the same stage later instead of skipping the
// proxy check. Takes ownership of pUser.
void DB_DeferClientCheck(ProxyUser pUser, bool fromRules)
{
	int retries = pUser.GetInt("db_retries");
	if (retries >= DB_CHECK_RETRY_MAX)
	{
		char name[MAX_NAME_LENGTH];
		pUser.GetName(name, sizeof(name));
		g_Logger.ErrorMessage("Database still not connected, skipping proxy check for \"%s\"", name);
		delete pUser;
		return;
	}

	pUser.SetValue("db_retries", retries + 1);
	pUser.SetValue("db_from_rules", fromRules);
	CreateTimer(DB_CHECK_RETRY_DELAY, DB_Timer_RetryClientCheck, pUser);
}

public Action DB_Timer_RetryClientCheck(Handle timer, any data)
{
	ProxyUser pUser = view_as<ProxyUser>(data);

	// Client left in the meantime
	if (pUser.Client == 0)
	{
		delete pUser;
		return Plugin_Stop;
	}

	if (pUser.GetBool("db_from_rules"))
	{
		TryGetRules(pUser);
	}
	else
	{
		QueryCache(pUser);
	}

	return Plugin_Stop;
}

// =========================================================== //
// Wrapper Functions for Each Database
// =========================================================== //

public bool ProxyCacheMySQL_DB_Connect()
{
	return DB_Connect(Idx_ProxyCacheMySQL, DBType_MySQL, DB_CONF_NAME);
}

public bool ProxyCacheSQLite_DB_Connect()
{
	return DB_Connect(Idx_ProxyCacheSQLite, DBType_SQLite, DB_CONF_NAME);
}

public bool ProxyRulesMySQL_DB_Connect()
{
	return DB_Connect(Idx_ProxyRulesMySQL, DBType_MySQL, DB_CONF_NAME);
}

public bool ProxyRulesSQLite_DB_Connect()
{
	return DB_Connect(Idx_ProxyRulesSQLite, DBType_SQLite, DB_CONF_NAME);
}

public bool ProxyCacheMySQL_DB_Conn_Lost(DBResultSet db, const char[] error)
{
	return DB_Conn_Lost(Idx_ProxyCacheMySQL, db, error);
}

public bool ProxyCacheSQLite_DB_Conn_Lost(DBResultSet db, const char[] error)
{
	return DB_Conn_Lost(Idx_ProxyCacheSQLite, db, error);
}

public bool ProxyRulesMySQL_DB_Conn_Lost(DBResultSet db, const char[] error)
{
	return DB_Conn_Lost(Idx_ProxyRulesMySQL, db, error);
}

public bool ProxyRulesSQLite_DB_Conn_Lost(DBResultSet db, const char[] error)
{
	return DB_Conn_Lost(Idx_ProxyRulesSQLite, db, error);
}

public Database ProxyCacheMySQL_DB_GetHandle()
{
	return g_hDatabases[Idx_ProxyCacheMySQL];
}

public Database ProxyCacheSQLite_DB_GetHandle()
{
	return g_hDatabases[Idx_ProxyCacheSQLite];
}

public Database ProxyRulesMySQL_DB_GetHandle()
{
	return g_hDatabases[Idx_ProxyRulesMySQL];
}

public Database ProxyRulesSQLite_DB_GetHandle()
{
	return g_hDatabases[Idx_ProxyRulesSQLite];
}
