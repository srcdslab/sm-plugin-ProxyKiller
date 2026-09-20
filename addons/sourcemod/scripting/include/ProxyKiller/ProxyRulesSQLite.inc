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
		// Resolves to the live, shared handle owned by databases.sp rather
		// than a handle of this instance's own, so it stays valid across
		// async (re)connects.
		public get() { return ProxyRulesSQLite_DB_GetHandle(); }
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
			CreateTimer(1.0, Timer_ProxyRulesSQLite_Initialize, this, TIMER_FLAG_NO_MAPCHANGE);
			return;
		}

		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		char query[sizeof(CREATE_TABLE) + sizeof(prefix)];
		db.Format(query, sizeof(query), CREATE_TABLE, prefix);

		db.Query(OnProxyRulesSQLiteTableCreated, query);
	}

	public void TryGetRules(ProxyUser pUser, ProxyRulesType type, SQLQueryCallback callback)
	{
		char steamId2[32];
		pUser.GetSteamId2(steamId2, sizeof(steamId2));

		char ipAddress[16];
		pUser.GetIPAddress(ipAddress, sizeof(ipAddress));

		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		Database db = this.Provider;

		char steamId2Esc[32 * 2 + 1], ipAddressEsc[16 * 2 + 1];
		db.Escape(steamId2, steamId2Esc, sizeof(steamId2Esc));
		db.Escape(ipAddress, ipAddressEsc, sizeof(ipAddressEsc));

		char query[512];
		db.Format(query, sizeof(query), SELECT_RECORD, prefix, steamId2Esc, ipAddressEsc, type);

		db.Query(callback, query, pUser);
	}

	public void TryPushRule(char[] expression, ProxyRulesType type, SQLQueryCallback callback)
	{
		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		Database db = this.Provider;

		char expressionEsc[64 * 2 + 1];
		db.Escape(expression, expressionEsc, sizeof(expressionEsc));

		char query[512];
		db.Format(query, sizeof(query), INSERT_RECORD, prefix, expressionEsc, type);

		db.Query(callback, query);
	}

	public void TryDeleteRule(char[] expression, ProxyRulesType type, SQLQueryCallback callback)
	{
		char prefix[64];
		this.GetTablePrefix(prefix, sizeof(prefix));

		Database db = this.Provider;

		char expressionEsc[64 * 2 + 1];
		db.Escape(expression, expressionEsc, sizeof(expressionEsc));

		char query[512];
		db.Format(query, sizeof(query), DELETE_RECORD, prefix, expressionEsc, type);

		db.Query(callback, query);
	}
}

public Action Timer_ProxyRulesSQLite_Initialize(Handle timer, any data)
{
	view_as<ProxyRulesSQLite>(data).Initialize();
	return Plugin_Continue;
}

public void OnProxyRulesSQLiteTableCreated(Database db, DBResultSet results, const char[] error, any data)
{
	if (results == null)
	{
		LogError("<Rules-SQLite> Failed to create rules table: %s", error);
	}
}

// =========================================================== //