// =========================================================== //

#include <json>
#include <regex>
#include <SteamWorks>
#include <ProxyKiller>

// ====================== FORMATTING ========================= //

#pragma dynamic 131072
#pragma newdecls required

// ====================== VARIABLES ========================== //

ProxyCache g_Cache = null;
ProxyRules g_Rules = null;
ProxyLogger g_Logger = null;
ProxyConfig g_Config = null;

// ======================= INCLUDES ========================== //

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

// ====================== PLUGIN INFO ======================== //

public Plugin myinfo =
{
	name = PROXYKILLER_NAME,
	author = PROXYKILLER_AUTHOR,
	description = PROXYKILLER_DESCRIPTION,
	version = PROXYKILLER_VERSION,
	url = PROXYKILLER_URL
};

// ======================= MAIN CODE ========================= //

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	CreateConVars();
	CreateForwards();
	CreateCommands();

	RegPluginLibrary(PROXYKILLER_NAME);
	AutoExecConfig(true);

	g_Logger = new ProxyLogger(PROXYKILLER_SPEWMODE, PROXYKILLER_SPEWLEVEL);
	Call_OnLogger();

	return APLRes_Success;
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
}

public void OnClientPostAdminCheck(int client)
{
	if (IsFakeClient(client) || !gCV_Enable.BoolValue)
	{
		return;
	}

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

	if (shouldIgnore)
	{
		// FUTURE FEATURE -> Check for blacklisted user
		LogMessage("Ignoring client %d", client)
	}
	else
	{
		if (Call_DoCheckClient(client))
		{
			ProxyKiller_CheckClient(client);
		}
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