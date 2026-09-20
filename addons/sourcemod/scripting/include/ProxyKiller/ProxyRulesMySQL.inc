// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyRulesMySQL_included_
#endinput
#endif
#define _ProxyRulesMySQL_included_

// =========================================================== //

static char CREATE_TABLE[] =
"CREATE TABLE `%s_Rules` "
..."("
..."`Expression` VARCHAR(32) NOT NULL, "
..."`Type` TINYINT NOT NULL, "
..."`Timestamp` TIMESTAMP NOT NULL DEFAULT "
..."CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, "
..."PRIMARY KEY (`Expression`)"
...")";

static char SELECT_RECORD[] =
"SELECT `Expression`, "
..."UNIX_TIMESTAMP(`Timestamp`) "
..."FROM `%s_Rules` "
..."WHERE `Expression` "
..."IN ('%s', '%s') "
..."AND `Type` = '%d'";

static char INSERT_RECORD[] =
"INSERT INTO `%s_Rules` "
..."(`Expression`, `Type`) "
..."VALUES ('%s', '%d') "
..."ON DUPLICATE KEY UPDATE "
..."`Type` = VALUES(`Type`), "
..."`Timestamp` = CURRENT_TIMESTAMP";

static char DELETE_RECORD[] =
"DELETE FROM `%s_Rules` "
..."WHERE `Expression` = '%s' "
..."AND `Type` = '%d'";

// =========================================================== //

methodmap ProxyRulesMySQL < ProxyRules
{
	public ProxyRulesMySQL(char[] tablePrefix)
	{
		ProxyRules rules = new ProxyRules(RulesMode_MySQL);
		rules.SetString("table_prefix", tablePrefix);
		return view_as<ProxyRulesMySQL>(rules);
	}

	property Database Provider
	{
		// Resolves to the live, shared handle owned by databases.sp rather
		// than a handle of this instance's own, so it stays valid across
		// async (re)connects.
		public get() { return ProxyRulesMySQL_DB_GetHandle(); }
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
			CreateTimer(1.0, Timer_ProxyRulesMySQL_Initialize, this, TIMER_FLAG_NO_MAPCHANGE);
			return;
		}

		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		char query[sizeof(CREATE_TABLE) + sizeof(prefix)];
		db.Format(query, sizeof(query), CREATE_TABLE, prefix);

		db.Query(OnProxyRulesMySQLTableCreated, query);
	}

	public void TryGetRules(ProxyUser pUser, ProxyRulesType type, SQLQueryCallback callback)
	{
		char steamId2[32];
		pUser.GetSteamId2(steamId2, sizeof(steamId2));
		
		char ipAddress[16];
		pUser.GetIPAddress(ipAddress, sizeof(ipAddress));
		
		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		char query[512];
		this.Provider.Format(query, sizeof(query), SELECT_RECORD, prefix, steamId2, ipAddress, type);

		this.Provider.Query(callback, query, pUser);
	}
	
	public void TryPushRule(char[] expression, ProxyRulesType type, SQLQueryCallback callback)
	{
		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		char query[512];
		this.Provider.Format(query, sizeof(query), INSERT_RECORD, prefix, expression, type);

		this.Provider.Query(callback, query);
	}
	
	public void TryDeleteRule(char[] expression, ProxyRulesType type, SQLQueryCallback callback)
	{
		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));		

		char query[512];
		this.Provider.Format(query, sizeof(query), DELETE_RECORD, prefix, expression, type);

		this.Provider.Query(callback, query);
	}
}

public Action Timer_ProxyRulesMySQL_Initialize(Handle timer, any data)
{
	view_as<ProxyRulesMySQL>(data).Initialize();
	return Plugin_Continue;
}

public void OnProxyRulesMySQLTableCreated(Database db, DBResultSet results, const char[] error, any data)
{
	if (results == null)
	{
		LogError("<Rules-MySQL> Failed to create rules table: %s", error);
	}
}

// =========================================================== //