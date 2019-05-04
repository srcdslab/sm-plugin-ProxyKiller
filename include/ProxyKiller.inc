// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyKiller_included_
#endinput
#endif
#define _ProxyKiller_included_

// =========================================================== //

#include <StringMapEx>

#include <ProxyKiller/ProxyHTTPParams>
#include <ProxyKiller/ProxyHTTPHeaders>
#include <ProxyKiller/ProxyHTTPResponse>

#include <ProxyKiller/ProxyHTTP>
#include <ProxyKiller/ProxyHTTPContext>

#include <ProxyKiller/ProxyUser>
#include <ProxyKiller/ProxyServiceResponse>

#include <ProxyKiller/ProxyService>
#include <ProxyKiller/ProxyServiceContext>

#include <ProxyKiller/ProxyCache>
#include <ProxyKiller/ProxyConfig>
#include <ProxyKiller/ProxyLogger>
#include <ProxyKiller/ProxyCacheMySQL>

// =========================================================== //

#tryinclude <ProxyKiller_Version>

#if !defined PROXYKILLER_URL
#define PROXYKILLER_URL "Built from <Unknown>"
#endif

#if !defined PROXYKILLER_VERSION
#define PROXYKILLER_VERSION "Unknown Version"
#endif

#if !defined PROXYKILLER_SPEWMODE
#define PROXYKILLER_SPEWMODE (SPEWMODE_LOG | SPEWMODE_CHAT)
#endif

#if !defined PROXYKILLER_SPEWLEVEL
#define PROXYKILLER_SPEWLEVEL (SPEWLEVEL_ERRORS | SPEWLEVEL_INFO | SPEWLEVEL_DEBUG)
#endif

// =========================================================== //

#define PROXYKILLER_NAME "ProxyKiller"
#define PROXYKILLER_AUTHOR "Sikari"
#define PROXYKILLER_DESCRIPTION "Kill them proxies!"
#define PROXYKILLER_CONFIG "cfg/sourcemod/ProxyKiller-Config.cfg"

#define MAX_URL_LENGTH 256
#define MAX_PUNISHMENT_LOG_LENGTH 512
#define MAX_PUNISHMENT_MESSAGE_LENGTH 256

// =========================================================== //

enum
{
	Punishment_Kick = 0,
	Punishment_Ban
};

// =========================================================== //

typeset ProxyHTTPCallback
{
	function void (ProxyHTTPResponse response, const char[] responseData);
	function void (ProxyHTTPResponse response, const char[] responseData, any data);
};

// =========================================================== //

native void ProxyKiller_CheckClient(int client);

native void ProxyKiller_SendHTTPRequest(ProxyHTTP http, ProxyHTTPCallback callback = INVALID_FUNCTION, any data = 0);
native ProxyHTTP ProxyKiller_CreateHTTP(const char[] url, ProxyHTTPMethod method = HTTPMethod_GET, isPersistent = false);

// =========================================================== //

forward void ProxyKiller_OnCache(CacheMode mode);
forward void ProxyKiller_OnConfig(ProxyConfig config);
forward void ProxyKiller_OnValidClient(int client);

forward Action ProxyKiller_DoCheckClient(int client);
forward void ProxyKiller_OnCheckClient(ProxyUser pUser);

forward void ProxyKiller_OnClientResult(ProxyUser pUser, bool result, bool fromCache);

forward Action ProxyKiller_DoClientResultCache(ProxyUser pUser, bool result);
forward void ProxyKiller_OnClientResultCache(ProxyUser pUser, bool result);

forward Action ProxyKiller_DoClientPunishment(ProxyUser pUser, bool fromCache);
forward void ProxyKiller_OnClientPunishment(ProxyUser pUser, bool fromCache);

// =========================================================== //