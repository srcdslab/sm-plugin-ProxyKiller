// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyRulesSQLite_included_
#endinput
#endif
#define _ProxyRulesSQLite_included_

// =========================================================== //

static char CREATE_TABLE[] =
"CREATE TABLE `%s_Rules` "
..."("
..."`Expression` VARCHAR(32) NOT NULL, "
..."`Type` TINYINT NOT NULL, "
..."`Timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, "
..."PRIMARY KEY (`Expression`)"
...")";

static char SELECT_RECORD[] =
"SELECT `Expression`, "
..."strftime('%%s', `Timestamp`) "
..."FROM `%s_Rules` "
..."WHERE `Expression` "
..."IN ('%s', '%s') "
..."AND `Type` = '%d'";

static char INSERT_RECORD[] =
"INSERT OR REPLACE INTO `%s_Rules` "
..."(`Expression`, `Type`, `Timestamp`) "
..."VALUES ('%s', '%d', CURRENT_TIMESTAMP)"

static char DELETE_RECORD[] =
"DELETE FROM `%s_Rules` "
..."WHERE `Expression` = '%s' "
..."AND `Type` = '%d'";

// =========================================================== //

methodmap ProxyRulesSQLite < ProxyRules
{
	public ProxyRulesSQLite(char[] tablePrefix)
	{
		ProxyRules rules = new ProxyRules(RulesMode_SQLite);
		rules.SetString("table_prefix", tablePrefix);
		return view_as<ProxyRulesSQLite>(rules);
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

// =========================================================== //