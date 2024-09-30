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

// Database indices for easy access
#define Idx_ProxyCacheMySQL 0
#define Idx_ProxyCacheSQLite 1
#define Idx_ProxyRulesMySQL 2
#define Idx_ProxyRulesSQLite 3

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
		Database.Connect(DB_GotDatabase, dbName, dbIndex);
	}

	return false;
}

public void DB_GotDatabase(Database db, const char[] error, any data)
{
	int dbIndex = view_as<int>(data);

	if (db == null)
	{
		LogError("Connecting to database failed: %s", error);
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
	if (g_iConnectLocks[dbIndex] != data || (g_hDatabases[dbIndex] != null && g_DatabaseStates[dbIndex] == DatabaseState_Connected))
	{
		if (db)
			delete db;
		return;
	}

	char sDriver[16];
	SQL_GetDriverIdent(db.Driver, sDriver, sizeof(sDriver));

	if ((dbIndex == Idx_ProxyCacheMySQL || dbIndex == Idx_ProxyCacheSQLite) && !StrEqual(sDriver, "mysql", false))
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
}

public bool DB_Conn_Lost(int dbIndex, DBResultSet db)
{
	if (db == null)
	{
		float fRetryTime = 10.0;
		if (g_hDatabases[dbIndex] != null)
		{
			LogError("Lost connection to DB. Reconnect after delay of %0.f seconds.", fRetryTime);
			delete g_hDatabases[dbIndex];
			g_hDatabases[dbIndex] = null;
		}

		if (g_DatabaseStates[dbIndex] != DatabaseState_Wait && g_DatabaseStates[dbIndex] != DatabaseState_Connecting)
		{
			g_DatabaseStates[dbIndex] = DatabaseState_Wait;
			CreateTimer(fRetryTime, DB_TimerDB_Reconnect, dbIndex, TIMER_FLAG_NO_MAPCHANGE);
		}

		return true;
	}

	return false;
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

public bool ProxyCacheMySQL_DB_Conn_Lost(DBResultSet db)
{
	return DB_Conn_Lost(Idx_ProxyCacheMySQL, db);
}

public bool ProxyCacheSQLite_DB_Conn_Lost(DBResultSet db)
{
	return DB_Conn_Lost(Idx_ProxyCacheSQLite, db);
}

public bool ProxyRulesMySQL_DB_Conn_Lost(DBResultSet db)
{
	return DB_Conn_Lost(Idx_ProxyRulesMySQL, db);
}

public bool ProxyRulesSQLite_DB_Conn_Lost(DBResultSet db)
{
	return DB_Conn_Lost(Idx_ProxyRulesSQLite, db);
}
