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

methodmap ProxyCacheMySQL < Database
{
	public ProxyCacheMySQL()
	{
		Database database = null;
		bool validDriver = EnsureDBDriver(MYSQL_DB_CONF, "mysql");
		
		if (validDriver)
		{	
			char error[256] = "Unknown";
			database = SQL_Connect(MYSQL_DB_CONF, true, error, sizeof(error));
			
			if (database == null)
			{
				SetFailState("<Cache-MySQL> Error connecting to configuration \"%s\"", MYSQL_DB_CONF);
			}
		}
		else
		{
			SetFailState("<Cache-MySQL> Invalid database driver for \"%s\", expecting \"mysql\"", MYSQL_DB_CONF);
		}

		return view_as<ProxyCacheMySQL>(database);
	}
	
	public void Initialize()
	{
		// non async monkaS
		SQL_LockDatabase(this);
		SQL_FastQuery(this, CREATE_TABLE);
		SQL_UnlockDatabase(this);
	}
	
	public void TryGet(ProxyUser pUser, ProxyService service, SQLQueryCallback callback)
	{
		char ipAddress[24];
		pUser.GetIPAddress(ipAddress, sizeof(ipAddress));
		
		char serviceName[MAX_SERVICE_NAME_LENGTH];
		service.GetName(serviceName, sizeof(serviceName));
		
		char query[512];
		Format(query, sizeof(query), SELECT_RECORD, ipAddress, serviceName);
		this.Query(callback, query, pUser);
	}
	
	public void TryCache(ProxyUser pUser, ProxyService service, any result, SQLQueryCallback callback)
	{
		char ipAddress[24];
		pUser.GetIPAddress(ipAddress, sizeof(ipAddress));
		
		char serviceName[MAX_SERVICE_NAME_LENGTH];
		service.GetName(serviceName, sizeof(serviceName));
		
		char query[512];
		Format(query, sizeof(query), INSERT_RECORD, ipAddress, serviceName, result, result);
		this.Query(callback, query);
	}
}

// =========================================================== //