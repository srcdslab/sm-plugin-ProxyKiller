// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCacheMySQL_included_
#endinput
#endif
#define _ProxyCacheMySQL_included_

// =========================================================== //

static char CREATE_TABLE[] =
"CREATE TABLE `%s_Cache` "
..."("
..."`IPAddress` VARCHAR(24) NOT NULL, "
..."`ServiceName` VARCHAR(128) NOT NULL, "
..."`Result` TINYINT(1) NOT NULL, "
..."`Timestamp` TIMESTAMP NOT NULL DEFAULT "
..."CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, "
..."PRIMARY KEY (`IPAddress`, `ServiceName`)"
...")"

static char SELECT_RECORD[] =
"SELECT `IPAddress`, `ServiceName`, "
..."`Result`, UNIX_TIMESTAMP(`Timestamp`) "
..."FROM `%s_Cache` "
..."WHERE `IPAddress` = '%s' "
..."AND `ServiceName` = '%s'";

static char INSERT_RECORD[] =
"INSERT INTO `%s_Cache` "
..."(`IPAddress`, `ServiceName`, `Result`) "
..."VALUES ('%s', '%s', '%d') "
..."ON DUPLICATE KEY UPDATE "
..."`Result` = VALUES(`Result`), "
..."`Timestamp` = CURRENT_TIMESTAMP";

static char DELETE_OLD_RECORDS[] =
"DELETE FROM `%s_Cache` "
..."WHERE (UNIX_TIMESTAMP() - UNIX_TIMESTAMP(`Timestamp`)) > %d"

methodmap ProxyCacheMySQL < ProxyCache
{
	public ProxyCacheMySQL(char[] tablePrefix)
	{
		ProxyCache cache = new ProxyCache(CacheMode_MySQL);
		cache.SetString("table_prefix", tablePrefix);
		return view_as<ProxyCacheMySQL>(cache);
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
		SQL_FastQuery(this.Provider, query);
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