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
#define PROXYKILLER_URL "Unknown source"
#endif

#if !defined PROXYKILLER_VERSION
#define PROXYKILLER_VERSION "Unknown version"
#endif

#if !defined PROXYKILLER_SPEWMODE
#define PROXYKILLER_SPEWMODE (SPEWMODE_LOG)
#endif

#if !defined PROXYKILLER_SPEWLEVEL
#define PROXYKILLER_SPEWLEVEL (SPEWLEVEL_ERRORS | SPEWLEVEL_INFO)
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

/**
 * Types of punishments available
 */
enum
{
	Punishment_None = 0, 	/**< No punishment */
	Punishment_Kick, 		/**< Kick the client */
	Punishment_Ban,			/**< Ban the client */
	Punishment_COUNT
};

// =========================================================== //

/*
	Function types when ProxyHTTP call finishes
*/
typeset ProxyHTTPCallback
{
   /**
 	* Called when a ProxyHTTP call finishes
 	*
 	* @param response			ProxyHTTPResponse object containing response metadata
 	* @param responseData		The entire response body as string representation
 	* @noreturn
 	*/
	function void (ProxyHTTPResponse response, const char[] responseData);

   /**
 	* Called when a ProxyHTTP call finishes
 	*
 	* @param response			ProxyHTTPResponse object containing response metadata
 	* @param responseData		The entire response body as string representation
 	* @param data				Any additional data you may have passed
 	* @noreturn
 	*/
	function void (ProxyHTTPResponse response, const char[] responseData, any data);
};

// =========================================================== //

/**
 * Gets the ProxyCache used by ProxyKiller
 *
 * @return						ProxyCache object being used by ProxyKiller		
 */
native ProxyCache ProxyKiller_GetCache();

/**
 * Gets the ProxyConfig used by ProxyKiller
 *
 * @return						ProxyConfig object being used by ProxyKiller
 */
native ProxyConfig ProxyKiller_GetConfig();

/**
 * Gets the ProxyLogger used by ProxyKiller
 *
 * @return						ProxyLogger object being used by ProxyKiller		
 */
native ProxyLogger ProxyKiller_GetLogger();

/**
 * Gets whether cache is initialized for ProxyKiller
 *
 * @return						Whether cache was initialized for ProxyKiller		
 */
native bool ProxyKiller_IsCacheInit();

/**
 * Tells ProxyKiller to check the specified client
 *
 * @param client				Client index of the client to check
 * @noreturn		
 */
native void ProxyKiller_CheckClient(int client);

/**
 * Sends a ProxyHTTP request and calls the callback function when done
 *
 * @param http					ProxyHTTP object of http metadata
 * @param callback				ProxyHTTPCallback to call when request is done
 * @param data					Optional data to pass to the callback
 * @return						Whether the request was successfully made
 */
native bool ProxyKiller_SendHTTPRequest(ProxyHTTP http, ProxyHTTPCallback callback = INVALID_FUNCTION, any data = 0);

/**
 * Creates a ProxyHTTP instance and returns it
 *
 * @param url					URI of the http request
 * @param method				ProxyHTTPMethod of the http request
 * @param isPersistent			Whether the ProxyHTTP object is persistent (Kept in memory after finish)
 * @return						A ProxyHTTP object containing the metadata defined
 */
native ProxyHTTP ProxyKiller_CreateHTTP(const char[] url, ProxyHTTPMethod method = HTTPMethod_GET, isPersistent = false);

// =========================================================== //

/**
 * Called when the cache is initialized for ProxyKiller
 *
 * @noreturn
 */
forward void ProxyKiller_OnCache();

/**
 * Called when the config is initialized for ProxyKiller
 *
 * @noreturn
 */
forward void ProxyKiller_OnConfig();

/**
 * Called when the logger is initialized for ProxyKiller
 *
 * @noreturn
 */
forward void ProxyKiller_OnLogger();

/**
 * Called when a valid ProxyKiller client is connected
 *
 * @param client				Client index of the valid client
 * @noreturn
 */
forward void ProxyKiller_OnValidClient(int client);

/**
 * Called when a client is about to be checked
 *
 * @param client				Client index of the client about to be checked
 * @return						Return Plugin_Continue (or nothing) to proceed, any other return value indicates that we want to block execution
 */
forward Action ProxyKiller_DoCheckClient(int client);

/**
 * Called when a client is being checked
 *
 * @param pUser					ProxyUser object of the client being checked
 * @noreturn
 */
forward void ProxyKiller_OnCheckClient(ProxyUser pUser);

/**
 * Called when a result is fetched for a client
 *
 * @param pUser					ProxyUser object of the result's client
 * @param result				Boolean of the result
 * @param fromCache				Whether the result was from cache
 * @noreturn
 */
forward void ProxyKiller_OnClientResult(ProxyUser pUser, bool result, bool fromCache);

/**
 * Called when a client's result is about to be cached
 *
 * @param pUser					ProxyUser object of client whose result is about to be cached
 * @param result				Boolean of the result about to be cached
 * @return						Return Plugin_Continue (or nothing) to proceed, any other return value indicates that we want to block execution
 */
forward Action ProxyKiller_DoClientResultCache(ProxyUser pUser, bool result);

/**
 * Called when a client's result is being cached
 *
 * @param pUser					ProxyUser object of the client whose result is being cached
 * @param result				Boolean of the result being cached
 * @noreturn
 */
forward void ProxyKiller_OnClientResultCache(ProxyUser pUser, bool result);

/**
 * Called when a client is about to be punished
 *
 * @param pUser					ProxyUser object of the client about to be punished
 * @param fromCache				Whether the result that triggered this was from cache
 * @return						Return Plugin_Continue (or nothing) to proceed, any other return value indicates that we want to block execution
 */
forward Action ProxyKiller_DoClientPunishment(ProxyUser pUser, bool fromCache);

/**
 * Called when a client is being punished
 *
 * @param pUser					ProxyUser object of the client being punished
 * @param fromCache				Whether the result that triggered this was from cache
 * @noreturn
 */
forward void ProxyKiller_OnClientPunishment(ProxyUser pUser, bool fromCache);

// =========================================================== //