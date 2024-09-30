// =========================================================== //

static bool RulesInit = false;

#define Rules_MySQL(%1) view_as<ProxyRulesMySQL>(%1)
#define Rules_SQLite(%1) view_as<ProxyRulesSQLite>(%1)

// =========================================================== //

bool IsRulesInit()
{
	return RulesInit;
}

ProxyRules CreateRules(int mode)
{
	int minMode = view_as<int>(RulesMode_Inherit);
	int maxMode = view_as<int>(RulesMode_COUNT) - 1;

	if (mode < minMode) mode = minMode;
	else if (mode > maxMode) mode = maxMode;

	ProxyRules rules = null;
	ProxyRulesMode rm = view_as<ProxyRulesMode>(mode);

	if (rm == RulesMode_Inherit)
	{
		// Infinite loop if g_Cache.Mode can somehow return -1
		return CreateRules(view_as<int>(g_Cache.Mode));
	}

	switch (rm)
	{
		case RulesMode_None:
		{
			g_Logger.PrintFrame("None");
			rules = new ProxyRules(rm);
		}
		case RulesMode_MySQL:
		{
			ProxyRulesMySQL_DB_Connect();

			char prefix[64];
			gCV_DatabaseTablePrefix.GetString(prefix, sizeof(prefix));
			
			g_Logger.PrintFrame("MySQL");
			rules = new ProxyRulesMySQL(prefix);
			Rules_MySQL(rules).Initialize();
		}
		case RulesMode_SQLite:
		{
			ProxyRulesSQLite_DB_Connect();

			char prefix[64];
			gCV_DatabaseTablePrefix.GetString(prefix, sizeof(prefix));

			g_Logger.PrintFrame("SQLite");
			rules = new ProxyRulesSQLite(prefix);
			Rules_SQLite(rules).Initialize();
		}
		default:
		{
			g_Logger.DebugMessage("Rules mode %d has no implementation for CreateRules", rm);
		}
	}

	RulesInit = true;
	return rules;
}

void TryGetRules(ProxyUser pUser, ProxyRulesType type = RulesType_Whitelist)
{
	switch (g_Rules.Mode)
	{
		case RulesMode_None:
		{
			TryGetCache(pUser);
		}
		case RulesMode_MySQL:
		{
			Rules_MySQL(g_Rules).TryGetRules(pUser, type, MySQL_OnRules);
		}
		case RulesMode_SQLite:
		{
			Rules_SQLite(g_Rules).TryGetRules(pUser, type, SQLite_OnRules);
		}
		default:
		{
			g_Logger.DebugMessage("Rules mode %d has no implementation for TryGetRules", g_Rules.Mode);
		}
	}
}

void TryPushRule(char[] expression, ProxyRulesType type = RulesType_Whitelist)
{
	switch (g_Rules.Mode)
	{
		case RulesMode_MySQL:
		{
			Rules_MySQL(g_Rules).TryPushRule(expression, type, MySQL_OnRuleGeneric);
		}
		case RulesMode_SQLite:
		{
			Rules_SQLite(g_Rules).TryPushRule(expression, type, SQLite_OnRuleGeneric);
		}
		default:
		{
			g_Logger.DebugMessage("Rules mode %d has no implementation for TryPushRule", g_Rules.Mode);
		}
	}
}

void TryDeleteRule(char[] expression, ProxyRulesType type = RulesType_Whitelist)
{
	switch (g_Rules.Mode)
	{
		case RulesMode_MySQL:
		{
			Rules_MySQL(g_Rules).TryDeleteRule(expression, type, MySQL_OnRuleGeneric);
		}
		case RulesMode_SQLite:
		{
			Rules_SQLite(g_Rules).TryDeleteRule(expression, type, SQLite_OnRuleGeneric);
		}
		default:
		{
			g_Logger.DebugMessage("Rules mode %d has no implementation for TryDeleteRule", g_Rules.Mode);
		}
	}
}

public void Rules_DB_Conn_Lost(DBResultSet results)
{
	switch (g_Rules.Mode)
	{
		case RulesMode_MySQL:
		{
			ProxyRulesMySQL_DB_Conn_Lost(results);
		}
		case RulesMode_SQLite:
		{
			ProxyRulesSQLite_DB_Conn_Lost(results);
		}
		default:
		{
			g_Logger.DebugMessage("Rules mode %d has no implementation for DB_Conn_Lost", g_Rules.Mode);
		}
	}
}

// =========================================================== //