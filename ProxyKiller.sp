// =========================================================== //

#include <json>
#include <SteamWorks>
#include <ProxyKiller>

// ====================== FORMATTING ========================= //

#pragma dynamic 131072
#pragma newdecls required

// ====================== VARIABLES ========================== //

ProxyCache g_Cache = null;
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

#include "ProxyKiller/cache/cache.sp"
#include "ProxyKiller/cache/mysql.sp"

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
	AutoExecConfig(true, PROXYKILLER_NAME ... "-Convars");
	g_Logger = new ProxyLogger(PROXYKILLER_SPEWMODE, PROXYKILLER_SPEWLEVEL);
}

public void OnConfigsExecuted()
{
	g_Config = ParseConfig(PROXYKILLER_CONFIG);
	Call_OnConfig(g_Config);

	g_Cache = CreateCache(gCV_CacheMode.IntValue);
	Call_OnCache(g_Cache.Mode);
}

public void OnClientPostAdminCheck(int client)
{
	if (IsFakeClient(client) || !gCV_Enable.BoolValue)
	{
		return;
	}

	Call_OnValidClient(client);

	char ignoreApps[256];
	gCV_IgnoreAppOwners.GetString(ignoreApps, sizeof(ignoreApps));

	TrimString(ignoreApps);
	bool shouldCheck = true;

	if (strlen(ignoreApps) > 0)
	{
		shouldCheck = HasAppFrom(client, ignoreApps);
	}

	if (shouldCheck)
	{
		bool blockExec = Call_DoCheckClient(client) != Plugin_Continue;
		if (!blockExec)
		{
			ProxyKiller_CheckClient(client);
		}
	}
}

// =========================================================== //