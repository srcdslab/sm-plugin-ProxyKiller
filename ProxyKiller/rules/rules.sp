// =========================================================== //

static bool gB_RulesInit = false;

#define Rules_MySQL(%1) view_as<ProxyRulesMySQL>(%1)

// =========================================================== //

bool IsRulesInit()
{
	return gB_RulesInit;
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
			g_Logger.PrintFrame("MySQL");
			rules = new ProxyRulesMySQL();
			Rules_MySQL(rules).Initialize();
		}
		default:
		{
			g_Logger.DebugMessage("Rules mode %d has no implementation for CreateRules", rm);
		}
	}

	gB_RulesInit = true;
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
		default:
		{
			g_Logger.DebugMessage("Rules mode %d has no implementation for TryDeleteRule", g_Rules.Mode);
		}
	}
}

// =========================================================== //