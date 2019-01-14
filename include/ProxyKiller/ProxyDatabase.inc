// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyDatabase_included_
#endinput
#endif
#define _ProxyDatabase_included_

// =========================================================== //

#define DATABASE_CONF "ProxyKiller"

static char CREATE_TABLE_CACHE[] =
"CREATE TABLE IF NOT EXISTS `ProxyKiller_Cache` ("
..."`ip` VARCHAR(24) PRIMARY KEY, "
..."`should_block` BOOLEAN NOT NULL, "
..."`timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);";

// =========================================================== //

methodmap ProxyDatabase < Database
{
	public ProxyDatabase()
	{
		char error[256] = "Unknown";
		Database db = SQL_Connect(DATABASE_CONF, true, error, sizeof(error));
		
		if (db == null)
		{
			SetFailState("Error connecting to configuration \"%s\" - Error: \"%s\"", DATABASE_CONF, error);
		}

		return view_as<ProxyDatabase>(db);
	}
	
	public void Initialize()
	{
		SQL_LockDatabase(this);
		SQL_FastQuery(this, CREATE_TABLE_CACHE);
		SQL_UnlockDatabase(this);
	}
	
	property Database db
	{
		public get() { return this; }
	}
}

// =========================================================== //