// =========================================================== //

#include <json>
#include <SteamWorks>
#include <ProxyKiller>

// ====================== FORMATTING ========================= //

#pragma dynamic 131072
#pragma newdecls required

// ====================== VARIABLES ========================== //

ProxyCache g_Cache = null;
ProxyRules g_Rules = null;
ProxyConfig g_Config = null;
ProxyLogger g_Logger = null;

// ======================= INCLUDES ========================== //

#include "ProxyKiller/api/natives.sp"
#include "ProxyKiller/api/convars.sp"
#include "ProxyKiller/api/forwards.sp"

#include "ProxyKiller/http/public/public.sp"
#include "ProxyKiller/http/public/params.sp"
#include "ProxyKiller/http/public/headers.sp"

#include "ProxyKiller/http/service/service.sp"
#include "ProxyKiller/http/service/helpers.sp"
#include "ProxyKiller/http/service/response.sp"

#include "ProxyKiller/config.sp"
#include "ProxyKiller/helpers.sp"
#include "ProxyKiller/tokenizer.sp"
#include "ProxyKiller/commands.sp"

#include "ProxyKiller/cache/cache.sp"
#include "ProxyKiller/cache/mysql.sp"

#include "ProxyKiller/rules/rules.sp"
#include "ProxyKiller/rules/mysql.sp"

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
	AutoExecConfig(true, PROXYKILLER_NAME ... "-Convars");

	g_Logger = new ProxyLogger(PROXYKILLER_SPEWMODE, PROXYKILLER_SPEWLEVEL);
	Call_OnLogger();
}

public void OnConfigsExecuted()
{
	g_Config = ParseConfig(PROXYKILLER_CONFIG);
	Call_OnConfig();

	g_Cache = CreateCache(gCV_CacheMode.IntValue);
	Call_OnCache();
	
	g_Rules = CreateRules(gCV_RulesMode.IntValue);
	Call_OnRules();
}

public void OnClientPostAdminCheck(int client)
{
	if (IsFakeClient(client) || !gCV_Enable.BoolValue)
	{
		return;
	}

	bool shouldIgnore = false;
	Call_OnValidClient(client);

	char ignoreFlags[64];
	gCV_IgnoreFlags.GetString(ignoreFlags, sizeof(ignoreFlags));

	TrimString(ignoreFlags);
	if (!shouldIgnore && strlen(ignoreFlags) > 0)
	{
		shouldIgnore = HasFlagFrom(client, ignoreFlags);
	}

	char ignoreApps[256];
	gCV_IgnoreAppOwners.GetString(ignoreApps, sizeof(ignoreApps));

	TrimString(ignoreApps);
	if (!shouldIgnore && strlen(ignoreApps) > 0)
	{
		shouldIgnore = HasAppFrom(client, ignoreApps);
	}

	if (shouldIgnore)
	{
		// FUTURE FEATURE -> Check for blacklisted user
	}
	else
	{
		if (Call_DoCheckClient(client))
		{
			ProxyKiller_CheckClient(client);
		}
	}
}

// =========================================================== //