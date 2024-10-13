// =========================================================== //

#include <json>
#include <regex>
#include <SteamWorks>
#include <ProxyKiller>

// ====================== FORMATTING ========================= //

#pragma dynamic 131072
#pragma newdecls required

// ====================== VARIABLES ========================== //

bool g_bBlackListed[MAXPLAYERS + 1] = {false};

ProxyCache g_Cache = null;
ProxyRules g_Rules = null;
ProxyLogger g_Logger = null;
ProxyConfig g_Config = null;

// ======================= INCLUDES ========================== //

#include "ProxyKiller/databases.sp"

#include "ProxyKiller/api/natives.sp"
#include "ProxyKiller/api/convars.sp"
#include "ProxyKiller/api/forwards.sp"

#include "ProxyKiller/http/public/public.sp"
#include "ProxyKiller/http/public/params.sp"
#include "ProxyKiller/http/public/headers.sp"
#include "ProxyKiller/http/public/rawbody.sp"

#include "ProxyKiller/http/service/service.sp"
#include "ProxyKiller/http/service/helpers.sp"
#include "ProxyKiller/http/service/response.sp"

#include "ProxyKiller/cache/cache.sp"
#include "ProxyKiller/cache/mysql.sp"
#include "ProxyKiller/cache/sqlite.sp"

#include "ProxyKiller/rules/rules.sp"
#include "ProxyKiller/rules/mysql.sp"
#include "ProxyKiller/rules/sqlite.sp"

#include "ProxyKiller/helpers.sp"
#include "ProxyKiller/migrations.sp"
#include "ProxyKiller/string_utils.sp"

#include "ProxyKiller/config.sp"
#include "ProxyKiller/commands.sp"
#include "ProxyKiller/lists.sp"

// ====================== PLUGIN INFO ======================== //

public Plugin myinfo =
{
	name = PROXYKILLER_NAME,
	author = "Sikari, .Rushaway, maxime1907",
	description = "Kill them proxies!",
	version = "2.3.2",
	url = "https://github.com/srcdslab/sm-plugin-ProxyKiller"
};

// ======================= MAIN CODE ========================= //

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	CreateForwards();

	RegPluginLibrary(PROXYKILLER_NAME);

	g_Logger = new ProxyLogger(PROXYKILLER_SPEWMODE, PROXYKILLER_SPEWLEVEL);
	Call_OnLogger();

	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVars();
	CreateCommands();

	AutoExecConfig(true);
}

public void OnAllPluginsLoaded()
{
	CreateLists();
}

public void OnConfigsExecuted()
{
	if (!ProxyKiller_Config_IsInit())
	{
		g_Config = ParseConfig(PROXYKILLER_CONFIG);
		Call_OnConfig();
	}

	if (!ProxyKiller_Cache_IsInit())
	{
		g_Cache = CreateCache(gCV_CacheMode.IntValue);
		Call_OnCache();
	}

	if (!ProxyKiller_Rules_IsInit())
	{
		g_Rules = CreateRules(gCV_RulesMode.IntValue);
		Call_OnRules();
	}

	LoadWhitelist();
	LoadBlacklist();
}

public void OnClientPostAdminCheck(int client)
{
	if (IsFakeClient(client) || !gCV_Enable.BoolValue)
	{
		return;
	}

	VerifyClient(client);
}

void VerifyClient(int client)
{
	g_bBlackListed[client] = false;

	Call_OnValidClient(client);
	bool shouldIgnore = HasOverride(client);

	char ignoreFlags[64];
	gCV_IgnoreFlags.GetString(ignoreFlags, sizeof(ignoreFlags));

	TrimString(ignoreFlags);
	if (!shouldIgnore && strlen(ignoreFlags) > 0)
	{
		shouldIgnore = HasFlagFromFlagString(client, ignoreFlags);
	}

	char ignoreApps[256];
	gCV_IgnoreAppOwners.GetString(ignoreApps, sizeof(ignoreApps));

	TrimString(ignoreApps);
	if (!shouldIgnore && strlen(ignoreApps) > 0)
	{
		shouldIgnore = HasAppFromAppString(client, ignoreApps);
	}

	if (!shouldIgnore)
	{
		shouldIgnore = IsUserWhitelisted(client);
	}

	if (IsUserBlacklisted(client))
	{
		LogMessage("Blacklisted client %L", client);
		g_bBlackListed[client] = true;
		shouldIgnore = false;
	}

	if (shouldIgnore)
	{
		LogMessage("Ignoring client %L", client);
		return;
	}

	if (Call_DoCheckClient(client))
	{
		ProxyKiller_CheckClient(client);
	}
}

public void ProxyKiller_OnCache()
{
	// Every hour and immediately fired once
	Handle timer = CreateTimer(3600.0, Timer_DeleteOldCacheEntries, _, TIMER_REPEAT);
	if (timer != null)
	{
		TriggerTimer(timer);
	}
}

// =========================================================== //