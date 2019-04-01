// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCacheSQLite_included_
#endinput
#endif
#define _ProxyCacheSQLite_included_

// =========================================================== //

//TODO
#define SQLITE_DB_CONF "ProxyKiller"

//static char CREATE_TABLE[] = "";

//static char INSERT_RECORD[] = "";

//static char SELECT_RECORD[] = "";

// =========================================================== //

methodmap ProxyCacheSQLite < Database
{
	public ProxyCacheSQLite()
	{
		Database database = null;
		bool validDriver = EnsureDBDriver(SQLITE_DB_CONF, "sqlite");
		
		if (validDriver)
		{	
			char error[256] = "Unknown";
			database = SQL_Connect(SQLITE_DB_CONF, true, error, sizeof(error));

			if (database == null)
			{
				SetFailState("<Cache-SQLite> Error connecting to configuration \"%s\"", SQLITE_DB_CONF);
			}
		}
		else
		{
			SetFailState("<Cache-SQLite> Invalid database driver for \"%s\", expecting \"sqlite\"", SQLITE_DB_CONF);
		}

		return view_as<ProxyCacheSQLite>(database);
	}
	
	public void Initialize()
	{
		
	}
	
	public void TryGet(ProxyUser pUser, ProxyService service, SQLQueryCallback callback)
	{
		
	}
	
	public void TryCache(ProxyUser pUser, ProxyService service, any result, SQLQueryCallback callback)
	{
		
	}
}

// =========================================================== //