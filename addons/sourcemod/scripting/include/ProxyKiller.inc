// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyKiller_included_
#endinput
#endif
#define _ProxyKiller_included_

#define ProxyKiller_V_MAJOR   2
#define ProxyKiller_V_MINOR   4
#define ProxyKiller_V_PATCH   0

#define ProxyKiller_VERSION   "2.4.0"

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

#include <ProxyKiller/ProxyConfig>
#include <ProxyKiller/ProxyLogger>

#include <ProxyKiller/ProxyCache>
#include <ProxyKiller/ProxyCacheMySQL>
#include <ProxyKiller/ProxyCacheSQLite>

#include <ProxyKiller/ProxyRules>
#include <ProxyKiller/ProxyRulesMySQL>
#include <ProxyKiller/ProxyRulesSQLite>

// =========================================================== //

#if !defined PROXYKILLER_SPEWMODE
#define PROXYKILLER_SPEWMODE (SPEWMODE_LOG)
#endif

#if !defined PROXYKILLER_SPEWLEVEL
#define PROXYKILLER_SPEWLEVEL (SPEWLEVEL_ERROR | SPEWLEVEL_INFO)
#endif

// =========================================================== //

#define PROXYKILLER_NAME "ProxyKiller"
#define PROXYKILLER_CONFIG "addons/sourcemod/configs/proxykiller.cfg"
#define PROXYKILLER_WHITELIST "addons/sourcemod/configs/proxykiller_whitelist.ini"
#define PROXYKILLER_BLACKLIST "addons/sourcemod/configs/proxykiller_blacklist.ini"

#define MAX_HTTP_URL_LENGTH 256
#define MAX_CONFIG_VARIABLE_NAME 64
#define MAX_CONFIG_VARIABLE_VALUE 256
#define MAX_RESPONSE_NAME_LENGTH 128
#define MAX_RESPONSE_VALUE_LENGTH 128
#define MAX_RESPONSE_OBJECT_LENGTH 64
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
 * Tells ProxyKiller to check the specified client
 *
 * @param client				Client index of the client to check
 * @return						Boolean of whether the client is being checked
 * @error						Invalid client index passed
 */
native bool ProxyKiller_CheckClient(int client);

/**
 * Creates a ProxyHTTP instance and returns it
 *
 * @param url					URI of the http request
 * @param method				ProxyHTTPMethod of the http request
 * @param isPersistent			Whether the ProxyHTTP object is persistent (Kept in memory after finish)
 * @return						A ProxyHTTP object containing the metadata defined
 */
native ProxyHTTP ProxyKiller_CreateHTTP(const char[] url, ProxyHTTPMethod method = HTTPMethod_GET, isPersistent = false);

/**
 * Sends a ProxyHTTP request and calls the callback function when done
 *
 * @param http					ProxyHTTP object of http metadata
 * @param callback				ProxyHTTPCallback to call when request is done
 * @param data					Optional data to pass to the callback
 * @return						Boolean of whether the request was successfully made
 */
native bool ProxyKiller_SendHTTPRequest(ProxyHTTP http, ProxyHTTPCallback callback = INVALID_FUNCTION, any data = 0);

/**
 * Gets the raw version string from ProxyKiller
 *
 * @param buffer				Buffer for the raw version
 * @param maxlength				Maxlength of the |buffer|
 * @return						Boolean of whether `PlInfo_Version` property exists
 */
native bool ProxyKiller_GetRawVersion(char[] buffer, int maxlength);

/**
 * Gets the semantic version string from |version|
 * Pass "NULL_STRING" to get the semantic version from ProxyKiller
 *
 * @param version				Version string to get semantic version from
 * @param buffer				Buffer for the semantic version
 * @param maxlength				Maxlength of the |buffer|
 * @return						Whether |version| was valid semantic version format
 */
native bool ProxyKiller_GetSemVersion(const char[] version, char[] buffer, int maxlength);

/**
 * Gets the major semantic version from |version|
 * Pass "NULL_STRING" to get the major semantic version from ProxyKiller
 *
 * @param version				Version string to get major semantic version from
 * @return						-1 if |version| was invalid semantic version format, otherwise major semantic version
 */
native int ProxyKiller_GetMajorVersion(const char[] version);

/**
 * Gets the minor semantic version from |version|
 * Pass "NULL_STRING" to get the minor semantic version from ProxyKiller
 *
 * @param version				Version string to get minor semantic version from
 * @return						-1 if |version| was invalid semantic version format, otherwise minor semantic version
 */
native int ProxyKiller_GetMinorVersion(const char[] version);

/**
 * Gets the patch semantic version from |version|
 * Pass "NULL_STRING" to get the patch semantic version from ProxyKiller
 *
 * @param version				Version string to get patch semantic version from
 * @return						-1 if |version| was invalid semantic version format, otherwise patch semantic version
 */
native int ProxyKiller_GetPatchVersion(const char[] version);

/**
 * Gets whether cache is initialized for ProxyKiller
 *
 * @return						Whether cache was initialized for ProxyKiller
 */
native bool ProxyKiller_Cache_IsInit();

/**
 * Gets whether rules is initialized for ProxyKiller
 *
 * @return						Whether rules was initialized for ProxyKiller
 */
native bool ProxyKiller_Rules_IsInit();

/**
 * Gets the bitsum of spew mode from the ProxyKiller logger
 *
 * @return						Bitsum of spew mode from ProxyKiller logger
 */
native int ProxyKiller_Logger_GetSpewMode();

/**
 * Gets the bitsum of spew level from the ProxyKiller logger
 *
 * @return						Bitsum of spew level from ProxyKiller logger
 */
native int ProxyKiller_Logger_GetSpewLevel();

/**
 * Makes an informational message through ProxyKiller logger
 * This function respects the spew mode and level set on ProxyKiller logger
 *
 * @param format				Formatting rules
 * @param ...					Variable number of format parameters
 * @return						Boolean of whether the log message was made
 */
native bool ProxyKiller_Logger_InfoMessage(const char[] format, any ...);

/**
 * Makes an error message through ProxyKiller logger
 * This function respects the spew mode and level set on ProxyKiller logger
 *
 * @param format				Formatting rules
 * @param ...					Variable number of format parameters
 * @return						Boolean of whether the log message was made
 */
native bool ProxyKiller_Logger_ErrorMessage(const char[] format, any ...);

/**
 * Makes a debugging message through ProxyKiller logger
 * This function respects the spew mode and level set on ProxyKiller logger
 *
 * @param format				Formatting rules
 * @param ...					Variable number of format parameters
 * @return						Boolean of whether the log message was made
 */
native bool ProxyKiller_Logger_DebugMessage(const char[] format, any ...);

/**
 * Gets whether config is initialized for ProxyKiller
 *
 * @return						Whether config was initialized for ProxyKiller
 */
native bool ProxyKiller_Config_IsInit();

/**
 * Gets whether a config variable exists
 *
 * @param variable				Variable to look existence for
 * @return						Boolean of whether config variable exists
 */
native bool ProxyKiller_Config_HasVariable(const char[] variable);

/**
 * Gets the value of a config variable
 *
 * @param variable				Variable to get value from
 * @param buffer				Buffer for the variable value
 * @param maxlength				Maxlength of the |buffer|
 * @return						Boolean of whether config variable existed
 */
native bool ProxyKiller_Config_GetVariable(const char[] variable, char[] buffer, int maxlength);

/**
 * Gets the name of the configured service
 *
 * @param buffer				Buffer for the service name
 * @param maxlength				Maxlength of the |buffer|
 * @return						True on success, false otherwise
 */
native bool ProxyKiller_Config_GetServiceName(char[] buffer, int maxlength);

/**
 * Gets the response value of the configured service
 *
 * @param buffer				Buffer for the service response value
 * @param maxlength				Maxlength of the |buffer|
 * @return						True on success, false otherwise
 */
native bool ProxyKiller_Config_GetServiceResponseValue(char[] buffer, int maxlength);

/**
 * Gets the response object of the configured service
 *
 * @param buffer				Buffer for the response object
 * @param maxlength				Maxlength of the |buffer|
 * @return						True if response type is JSON, false otherwise
 */
native bool ProxyKiller_Config_GetServiceResponseObject(char[] buffer, int maxlength);

/**
 * Gets the response type of the configured service
 *
 * @return						ResponseType value from configured service
 */
native ResponseType ProxyKiller_Config_GetServiceResponseType();

/**
 * Gets the response compare type of the configured service
 *
 * @return						ResponseCompare value from configured service
 */
native ResponseCompare ProxyKiller_Config_GetServiceResponseCompare();

// =========================================================== //

/**
 * Called when the plugin becomes available.
 * 
 * @noreturn
 */
forward void ProxyKiller_OnPluginOK();

/**
 * Called when the plugin becomes unavailable.
 * This can happen when the plugin is reloaded or unloaded.
 * 
 * @noreturn
 */
forward void ProxyKiller_OnPluginNotOK();

/**
 * Called when the cache is initialized for ProxyKiller
 *
 * @noreturn
 */
forward void ProxyKiller_OnCache();

/**
 * Called when the rules is initialized for ProxyKiller
 *
 * @noreturn
 */
forward void ProxyKiller_OnRules();

/**
 * Called when the logger is initialized for ProxyKiller
 *
 * @noreturn
 */
forward void ProxyKiller_OnLogger();

/**
 * Called when the config is initialized for ProxyKiller
 *
 * @noreturn
 */
forward void ProxyKiller_OnConfig();

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
 * @param fromCache				Boolean of whether the result was from cache
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
 * @param fromBlacklist			Whether the result that triggered this was from blacklist
 * @return						Return Plugin_Continue (or nothing) to proceed, any other return value indicates that we want to block execution
 */
forward Action ProxyKiller_DoClientPunishment(ProxyUser pUser, bool fromCache, bool fromBlacklist);

/**
 * Called when a client is being punished
 *
 * @param pUser					ProxyUser object of the client being punished
 * @param fromCache				Whether the result that triggered this was from cache
 * @param fromBlacklist			Whether the result that triggered this was from blacklist
 * @noreturn
 */
forward void ProxyKiller_OnClientPunishment(ProxyUser pUser, bool fromCache, bool fromBlacklist);

// =========================================================== //

public SharedPlugin __pl_ProxyKiller =
{
	name = "ProxyKiller",
	file = "ProxyKiller.smx",
	#if defined REQUIRE_PLUGIN
	required = 1,
	#else
	required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_ProxyKiller_SetNTVOptional()
{
	MarkNativeAsOptional("ProxyKiller_CheckClient");
	MarkNativeAsOptional("ProxyKiller_CreateHTTP");
	MarkNativeAsOptional("ProxyKiller_SendHTTPRequest");

	MarkNativeAsOptional("ProxyKiller_GetRawVersion");
	MarkNativeAsOptional("ProxyKiller_GetSemVersion");
	MarkNativeAsOptional("ProxyKiller_GetMajorVersion");
	MarkNativeAsOptional("ProxyKiller_GetMinorVersion");
	MarkNativeAsOptional("ProxyKiller_GetPatchVersion");

	MarkNativeAsOptional("ProxyKiller_Cache_IsInit");
	MarkNativeAsOptional("ProxyKiller_Rules_IsInit");

	MarkNativeAsOptional("ProxyKiller_Logger_GetSpewMode");
	MarkNativeAsOptional("ProxyKiller_Logger_GetSpewLevel");
	MarkNativeAsOptional("ProxyKiller_Logger_InfoMessage");
	MarkNativeAsOptional("ProxyKiller_Logger_ErrorMessage");
	MarkNativeAsOptional("ProxyKiller_Logger_DebugMessage");

	MarkNativeAsOptional("ProxyKiller_Config_IsInit");
	MarkNativeAsOptional("ProxyKiller_Config_HasVariable");
	MarkNativeAsOptional("ProxyKiller_Config_GetVariable");
	MarkNativeAsOptional("ProxyKiller_Config_GetServiceName");
	MarkNativeAsOptional("ProxyKiller_Config_GetServiceResponseValue");
	MarkNativeAsOptional("ProxyKiller_Config_GetServiceResponseObject");
	MarkNativeAsOptional("ProxyKiller_Config_GetServiceResponseType");
	MarkNativeAsOptional("ProxyKiller_Config_GetServiceResponseCompare");
};
#endif

// =========================================================== //