// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCacheMySQL_included_
#endinput
#endif
#define _ProxyCacheMySQL_included_

// =========================================================== //

#define MYSQL_DB_CONF "ProxyKiller"

static char CREATE_TABLE[] =
"CREATE TABLE `ProxyKiller_Cache` "
..."("
..."`IPAddress` VARCHAR(24) NOT NULL, "
..."`ServiceName` VARCHAR(128) NOT NULL, "
..."`Result` TINYINT(1) NOT NULL, "
..."`Timestamp` TIMESTAMP NOT NULL DEFAULT "
..."CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, "
..."PRIMARY KEY (`IPAddress`, `ServiceName`)"
...")"

static char INSERT_RECORD[] =
"INSERT INTO `ProxyKiller_Cache` "
..."(`IPAddress`, `ServiceName`, `Result`) "
..."VALUES ('%s', '%s', '%d') "
..."ON DUPLICATE KEY UPDATE "
..."Result = '%d'";

static char SELECT_RECORD[] =
"SELECT `IPAddress`, `ServiceName`, "
..."`Result`, UNIX_TIMESTAMP(`Timestamp`) "
..."FROM ProxyKiller_Cache WHERE `IPAddress` = '%s' "
..."AND `ServiceName` = '%s'";

// =========================================================== //

methodmap ProxyCacheMySQL < ProxyCache
{
	public ProxyCacheMySQL()
	{
		char error[256] = "Unknown";
		Database db = SQL_Connect(MYSQL_DB_CONF, true, error, sizeof(error));

		if (db == null)
		{
			SetFailState("<Cache-MySQL> Error connecting to configuration \"%s\" \n%s", MYSQL_DB_CONF, error);
		}
		else
		{
			char driver[16];
			SQL_ReadDriver(db, driver, sizeof(driver));
			
			if (!StrEqual(driver, "mysql", false))
			{
				SetFailState("<Cache-MySQL> Invalid database driver for \"%s\", expecting \"mysql\"", MYSQL_DB_CONF);
			}
		}

		return view_as<ProxyCacheMySQL>(new ProxyCache(CM_MySQL, db));
	}
	
	// Override ProxyCache::Hndl
	property Database Hndl
	{
		public get() { return this.GetAny("hndl"); }
	}
	
	// Override ProxyCache::Initialize
	public void Initialize()
	{
		SQL_LockDatabase(this.Hndl);
		SQL_FastQuery(this.Hndl, CREATE_TABLE);
		SQL_UnlockDatabase(this.Hndl);
	}
	
	// Override ProxyCache::TryGetCache
	public void TryGetCache(ProxyUser pUser, ProxyService service)
	{
		char ipAddress[24];
		pUser.GetIPAddress(ipAddress, sizeof(ipAddress));
		
		char serviceName[MAX_SERVICE_NAME_LENGTH];
		service.GetName(serviceName, sizeof(serviceName));
		
		char query[512];
		Format(query, sizeof(query), SELECT_RECORD, ipAddress, serviceName);
		
		// TODO!!!
		Function callback = GetFunctionByName(INVALID_HANDLE, "MySQL_OnCache");
		this.Hndl.Query(view_as<SQLQueryCallback>(callback), query, pUser);
	}
	
	// Override ProxyCache::TryPushCache
	public void TryPushCache(ProxyUser pUser, ProxyService service, any result)
	{
		char ipAddress[24];
		pUser.GetIPAddress(ipAddress, sizeof(ipAddress));
		
		char serviceName[MAX_SERVICE_NAME_LENGTH];
		service.GetName(serviceName, sizeof(serviceName));
		
		char query[512];
		Format(query, sizeof(query), INSERT_RECORD, ipAddress, serviceName, result, result);
		
		// TODO!!!
		Function callback = GetFunctionByName(INVALID_HANDLE, "MySQL_OnCached");
		this.Hndl.Query(view_as<SQLQueryCallback>(callback), query); 
	}
}

// =========================================================== //