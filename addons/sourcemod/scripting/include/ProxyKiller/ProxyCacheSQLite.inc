// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCacheSQLite_included_
#endinput
#endif
#define _ProxyCacheSQLite_included_

// =========================================================== //

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
		ProxyCache cache = new ProxyCache(CacheMode_SQLite);
		cache.SetString("table_prefix", tablePrefix);
		return view_as<ProxyCacheSQLite>(cache);
	}

	property Database Provider
	{
		// Resolves to the live, shared handle owned by databases.sp rather
		// than a handle of this instance's own, so it stays valid across
		// async (re)connects.
		public get() { return ProxyCacheSQLite_DB_GetHandle(); }
	}

	public void GetTablePrefix(char[] buffer, int maxlength)
	{
		this.GetString("table_prefix", buffer, maxlength);
	}

	public void Initialize()
	{
		Database db = this.Provider;
		if (db == null)
		{
			CreateTimer(1.0, Timer_ProxyCacheSQLite_Initialize, this, TIMER_FLAG_NO_MAPCHANGE);
			return;
		}

		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		char query[sizeof(CREATE_TABLE) + sizeof(prefix)];
		db.Format(query, sizeof(query), CREATE_TABLE, prefix);

		db.Query(OnProxyCacheSQLiteTableCreated, query);
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

public Action Timer_ProxyCacheSQLite_Initialize(Handle timer, any data)
{
	view_as<ProxyCacheSQLite>(data).Initialize();
	return Plugin_Continue;
}

public void OnProxyCacheSQLiteTableCreated(Database db, DBResultSet results, const char[] error, any data)
{
	if (results == null)
	{
		LogError("<Cache-SQLite> Failed to create cache table: %s", error);
	}
}

// =========================================================== //