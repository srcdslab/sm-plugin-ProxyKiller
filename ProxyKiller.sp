// =========================================================== //

#include <json>
#include <SteamWorks>
#include <ProxyKiller>

// ====================== FORMATTING ========================= //

#pragma dynamic 131072
#pragma newdecls required

// ====================== VARIABLES ========================== //

ProxyCache g_Cache = null;
ProxyLogger g_Logger = null;
ProxyService g_Service = null;

// ======================= INCLUDES ========================== //

#include "ProxyKiller/api/natives.sp"
#include "ProxyKiller/api/convars.sp"
#include "ProxyKiller/api/forwards.sp"

#include "ProxyKiller/http/params.sp"
#include "ProxyKiller/http/headers.sp"
#include "ProxyKiller/http/response.sp"

#include "ProxyKiller/cache/mysql.sp"
#include "ProxyKiller/cache/sqlite.sp"

#include "ProxyKiller/http.sp"
#include "ProxyKiller/cache.sp"
#include "ProxyKiller/config.sp"
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
	g_Logger = new ProxyLogger();
	g_Service = ParseConfig(DEFAULT_CONFIG);
}

public void OnConfigsExecuted()
{
	// TODO: Hook gCV_cacheMode and re-create this handle
	g_Cache = new ProxyCache(GetCachingMethod());
}

public void OnClientPostAdminCheck(int client)
{
	if (IsFakeClient(client) || !gCV_Enable.BoolValue)
	{
		return;
	}

	char ignoreApps[256];
	gCV_IgnoreAppOwners.GetString(ignoreApps, sizeof(ignoreApps));
	
	TrimString(ignoreApps);
	bool shouldCheck = true;

	if (strlen(ignoreApps) > 0)
	{
		char appIds[16][16];
		int appCount = ExplodeString(ignoreApps, ",", appIds, sizeof(appIds), sizeof(appIds[]));

		for (int i = 0; i < appCount; i++)
		{
			if (HasApp(client, StringToInt(appIds[i])))
			{
				shouldCheck = false;
				break;
			}
		}
	}

	if (shouldCheck)
	{
		ProxyKiller_CheckClient(client);
	}
}

bool HasApp(int client, int appid)
{
	return (SteamWorks_HasLicenseForApp(client, appid) == k_EUserHasLicenseResultHasLicense);
}

// =========================================================== //