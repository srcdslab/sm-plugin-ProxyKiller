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

// =========================================================== //

#tryinclude <ProxyKiller_Version>

#if !defined PROXYKILLER_VERSION
#define PROXYKILLER_VERSION "Unknown Version"
#endif

#if !defined PROXYKILLER_URL
#define PROXYKILLER_URL "Built from <Unknown>"
#endif

// =========================================================== //

#define PROXYKILLER_NAME "ProxyKiller"
#define PROXYKILLER_AUTHOR "Sikari"
#define PROXYKILLER_DESCRIPTION "Kill them proxies!"
#define PROXYKILLER_CONFIG "cfg/sourcemod/ProxyKiller-Config.cfg"

#define MAX_URL_LENGTH 256
#define KICK_MESSAGE_LENGTH 256

#define MAX_RESPONSE_TYPE_LENGTH 32
#define MAX_RESPONSE_NAME_LENGTH 128
#define MAX_RESPONSE_VALUE_LENGTH 128

// =========================================================== //

typeset ProxyHTTPCallback
{
	function void (ProxyHTTPResponse response, const char[] responseData);
	function void (ProxyHTTPResponse response, const char[] responseData, any data);
};

// =========================================================== //

native ProxyHTTP ProxyKiller_CreateHTTP(const char[] url, ProxyHTTPMethod method = HTTPMethod_GET, isPersistent = false);

native void ProxyKiller_CheckClient(int client);
native void ProxyKiller_SendRequest(ProxyHTTP http, ProxyHTTPCallback callback = INVALID_FUNCTION, any data = 0);

// =========================================================== //

forward void ProxyKiller_OnConfig(ProxyConfig config);

forward Action ProxyKiller_DoCheckClient(int client);
forward void ProxyKiller_OnCheckClient(ProxyUser pUser);

forward void ProxyKiller_OnClientResult(ProxyUser pUser, bool result, bool fromCache);

forward Action ProxyKiller_DoClientResultCache(ProxyUser pUser, bool result);
forward void ProxyKiller_OnClientResultCache(ProxyUser pUser, bool result);

forward Action ProxyKiller_DoClientPunishment(ProxyUser pUser, bool fromCache);
forward void ProxyKiller_OnClientPunishment(ProxyUser pUser, bool fromCache);

// =========================================================== //