// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyKiller_included_
#endinput
#endif
#define _ProxyKiller_included_

// =========================================================== //

#include <ProxyKiller/ProxyLogger>
#include <ProxyKiller/ProxyServiceParams>
#include <ProxyKiller/ProxyService>
#include <ProxyKiller/ProxyServices>
#include <ProxyKiller/ProxyDatabase>
#include <ProxyKiller/ProxyCacheLayer>

// =========================================================== //

#define PROXYKILLER_NAME "ProxyKiller"
#define PROXYKILLER_AUTHOR "Sikari"
#define PROXYKILLER_DESCRIPTION "Kill them proxies!"
#define PROXYKILLER_VERSION "1.1.0-bf2f305"
#define PROXYKILLER_URL "https://bitbucket.org/Sikarii/ProxyKiller"

#define MAX_URL_LENGTH 256
#define MAX_TOKEN_NAME_LENGTH 128
#define MAX_TOKEN_VALUE_LENGTH 128

#define MAX_PARAM_NAME_LENGTH 128
#define MAX_PARAM_VALUE_LENGTH 128
#define MAX_SERVICE_NAME_LENGTH 128

#define KICK_MESSAGE_LENGTH 256
#define IP_CONF_TOKEN "{client_ip}"

// =========================================================== //