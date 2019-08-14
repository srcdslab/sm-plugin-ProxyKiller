// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyRulesMySQL_included_
#endinput
#endif
#define _ProxyRulesMySQL_included_

// =========================================================== //

static char DB_CONF_NAME[] = "ProxyKiller";

static char CREATE_TABLE[] =
"CREATE TABLE `ProxyKiller2_Rules` "
..."("
..."`Expression` VARCHAR(32) NOT NULL, "
..."`Timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."PRIMARY KEY (`Expression`)"
...")";

// Kind of bad? Currently designed for IP/SteamId
static char SELECT_RECORD[] =
"SELECT `Expression`, "
..."UNIX_TIMESTAMP(`Timestamp`) "
..."FROM ProxyKiller2_Rules "
..."WHERE `Expression` = '%s' "
..."OR `Expression` = '%s'";

static char INSERT_RECORD[] =
"INSERT INTO `ProxyKiller2_Rules` "
..."(`Expression`) "
..."VALUES ('%s') "
..."ON DUPLICATE KEY UPDATE "
..."Timestamp = CURRENT_TIMESTAMP";

static char DELETE_RECORD[] =
"DELETE FROM `ProxyKiller2_Rules` "
..."WHERE `Expression` = '%s'";

// =========================================================== //

methodmap ProxyRulesMySQL < ProxyRules
{
	public ProxyRulesMySQL()
	{
		char error[256] = "Unknown";
		Database db = SQL_Connect(DB_CONF_NAME, true, error, sizeof(error));

		if (db == null)
		{
			SetFailState("<Rules-MySQL> Error connecting to configuration \"%s\" \n%s", DB_CONF_NAME, error);
		}
		else
		{
			char driver[16];
			SQL_ReadDriver(db, driver, sizeof(driver));
			
			if (!StrEqual(driver, "mysql", false))
			{
				SetFailState("<Rules-MySQL> Invalid database driver for \"%s\", expecting \"mysql\"", DB_CONF_NAME);
			}
		}

		return view_as<ProxyRulesMySQL>(new ProxyRules(RulesMode_MySQL, db));
	}

	property Database Provider
	{
		public get() { return this.GetAny("provider"); }
	}
	
	public void Initialize()
	{
		SQL_LockDatabase(this.Provider);
		SQL_FastQuery(this.Provider, CREATE_TABLE);
		SQL_UnlockDatabase(this.Provider);
	}
	
	public void TryGetRules(ProxyUser pUser, SQLQueryCallback callback)
	{
		char steamId2[32];
		pUser.GetSteamId2(steamId2, sizeof(steamId2));
		
		char ipAddress[16];
		pUser.GetIPAddress(ipAddress, sizeof(ipAddress));
		
		char query[512];
		this.Provider.Format(query, sizeof(query), SELECT_RECORD, steamId2, ipAddress);

		this.Provider.Query(callback, query, pUser);
	}
	
	public void TryPushRule(char[] expression, SQLQueryCallback callback)
	{
		char query[512];
		this.Provider.Format(query, sizeof(query), INSERT_RECORD, expression);

		this.Provider.Query(callback, query);
	}
	
	public void TryDeleteRule(char[] expression, SQLQueryCallback callback)
	{
		char query[512];
		this.Provider.Format(query, sizeof(query), DELETE_RECORD, expression);

		this.Provider.Query(callback, query);
	}
}

// =========================================================== //