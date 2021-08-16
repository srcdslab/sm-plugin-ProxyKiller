// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCacheSQLite_included_
#endinput
#endif
#define _ProxyCacheSQLite_included_

// =========================================================== //

static char DB_CONF_NAME[] = "ProxyKiller";

static char CREATE_TABLE[] =
"CREATE TABLE `%s_Cache` "
..."("
..."`IPAddress` VARCHAR(24) NOT NULL, "
..."`ServiceName` VARCHAR(128) NOT NULL, "
..."`Result` TINYINT(1) NOT NULL, "
..."`Timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."PRIMARY KEY (`IPAddress`, `ServiceName`)"
...")"

static char SELECT_RECORD[] =
"SELECT `IPAddress`, `ServiceName`, "
..."`Result`, "
..."strftime('%%s', `Timestamp`) "
..."FROM `%s_Cache` "
..."WHERE `IPAddress` = '%s' "
..."AND `ServiceName` = '%s'";

static char INSERT_RECORD[] =
"INSERT OR REPLACE INTO `%s_Cache` "
..."(`IPAddress`, `ServiceName`, `Result`, `Timestamp`) "
..."VALUES ('%s', '%s', '%d', CURRENT_TIMESTAMP) ";

static char DELETE_OLD_RECORDS[] =
"DELETE FROM `%s_Cache` "
..."WHERE (strftime('%%s', CURRENT_TIMESTAMP) "
..."- strftime('%%s', `Timestamp`)) > %d"

// =========================================================== //

methodmap ProxyCacheSQLite < ProxyCache
{
	public ProxyCacheSQLite(char[] tablePrefix)
	{
		char error[256] = "Unknown";
		Database db = SQL_Connect(DB_CONF_NAME, true, error, sizeof(error));

		if (db == null)
		{
			SetFailState("<Cache-SQLite> Error connecting to configuration \"%s\" \n%s", DB_CONF_NAME, error);
		}
		else
		{
			char driver[16];
			SQL_ReadDriver(db, driver, sizeof(driver));
			
			if (!StrEqual(driver, "sqlite", false))
			{
				SetFailState("<Cache-SQLite> Invalid database driver for \"%s\", expecting \"sqlite\"", DB_CONF_NAME);
			}
		}

		ProxyCache cache = new ProxyCache(CacheMode_SQLite, db);
		cache.SetString("table_prefix", tablePrefix);
		return view_as<ProxyCacheSQLite>(cache);
	}

	property Database Provider
	{
		public get() { return this.GetAny("provider"); }
	}

	public void GetTablePrefix(char[] buffer, int maxlength)
	{
		this.GetString("table_prefix", buffer, maxlength);
	}

	public void Initialize()
	{
		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		char query[sizeof(CREATE_TABLE) + sizeof(prefix)];
		this.Provider.Format(query, sizeof(query), CREATE_TABLE, prefix);

		SQL_LockDatabase(this.Provider);
		SQL_Query(this.Provider, query);
		SQL_UnlockDatabase(this.Provider);
	}

	public void TryGetCache(ProxyUser pUser, ProxyService service, SQLQueryCallback callback)
	{
		char ipAddress[24];
		pUser.GetIPAddress(ipAddress, sizeof(ipAddress));
		
		char serviceName[MAX_SERVICE_NAME_LENGTH];
		service.GetName(serviceName, sizeof(serviceName));

		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		char query[512];
		this.Provider.Format(query, sizeof(query), SELECT_RECORD, prefix, ipAddress, serviceName);

		this.Provider.Query(callback, query, pUser);
	}

	public void TryPushCache(ProxyUser pUser, ProxyService service, any result, SQLQueryCallback callback)
	{
		char ipAddress[24];
		pUser.GetIPAddress(ipAddress, sizeof(ipAddress));
		
		char serviceName[MAX_SERVICE_NAME_LENGTH];
		service.GetName(serviceName, sizeof(serviceName));

		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		char query[512];
		this.Provider.Format(query, sizeof(query), INSERT_RECORD, prefix, ipAddress, serviceName, result);

		this.Provider.Query(callback, query);
	}
	
	public void TryDeleteOldEntries(int cacheLifeTime, SQLQueryCallback callback)
	{
		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		char query[256];
		this.Provider.Format(query, sizeof(query), DELETE_OLD_RECORDS, prefix, cacheLifeTime);
		
		this.Provider.Query(callback, query);
	}
}

// =========================================================== //