// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyKiller_included_
#endinput
#endif
#define _ProxyKiller_included_

// =========================================================== //

#include <StringMapEx>

#include <ProxyKiller/ProxyHTTPParams>
#include <ProxyKiller/ProxyHTTPHeaders>
#include <ProxyKiller/ProxyServiceResponse>

#include <ProxyKiller/ProxyHTTP>
#include <ProxyKiller/ProxyHTTPContext>

#include <ProxyKiller/ProxyService>

#include <ProxyKiller/ProxyUser>
#include <ProxyKiller/ProxyLogger>
#include <ProxyKiller/ProxyCache>
#include <ProxyKiller/ProxyServiceContext>

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

#define MAX_URL_LENGTH 256
#define KICK_MESSAGE_LENGTH 256

#define MAX_RESPONSE_TYPE_LENGTH 32
#define MAX_RESPONSE_NAME_LENGTH 128
#define MAX_RESPONSE_VALUE_LENGTH 128

// =========================================================== //

native void ProxyKiller_CheckClient(int client);
native void ProxyKiller_SendRequest(ProxyHTTP http, Function callback = INVALID_FUNCTION, any data = 0);

// =========================================================== //