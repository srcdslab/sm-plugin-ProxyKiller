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

#include "ProxyKiller/http/public.sp"
#include "ProxyKiller/http/params.sp"
#include "ProxyKiller/http/headers.sp"
#include "ProxyKiller/http/response.sp"

#include "ProxyKiller/cache/mysql.sp"

#include "ProxyKiller/cache.sp"
#include "ProxyKiller/config.sp"
#include "ProxyKiller/service.sp"
#include "ProxyKiller/helpers.sp"
#include "ProxyKiller/tokenizer.sp"

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
	AutoExecConfig(true, PROXYKILLER_NAME);
}

public void OnPluginStart()
{
	g_Config = ParseConfig(PROXYKILLER_CONFIG);
	Call_OnConfig(g_Config);
	
	g_Logger = new ProxyLogger(PROXYKILLER_SPEWMODE, PROXYKILLER_SPEWLEVEL);
}

public void OnConfigsExecuted()
{
	g_Cache = CreateCache(gCV_CacheMode.IntValue);
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

void InfoMessage(char[] message)
{
	LogMessage("- [I] %s", message);
}

// =========================================================== //