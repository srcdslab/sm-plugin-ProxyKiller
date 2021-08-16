#include <sourcemod>
#include <ProxyKiller>
#include <Discord>

#define PLUGIN_VERSION "1.0"

#pragma newdecls required

ConVar g_cSteamProfileURLPrefix, g_cIPDetailURLPrefix;

public Plugin myinfo = 
{
    name = "ProxyKillerDiscord",
    author = "maxime1907, Sikari",
    description = "Sends detected vpn players info to discord",
    version = PLUGIN_VERSION,
    url = ""
};

public void OnPluginStart()
{
    g_cSteamProfileURLPrefix = CreateConVar("sm_proxykiller_discord_steam_profile_url", "https://steamcommunity.com/profiles/", "URL of the steam profile");
    g_cIPDetailURLPrefix = CreateConVar("sm_proxykiller_discord_ip_details_url", "http://geoiplookup.net/ip/", "URL of the website that analyses the IP");

    AutoExecConfig(true);
}

public void ProxyKiller_OnClientResult(ProxyUser pUser, bool result, bool fromCache)
{
    if (!result) return;
    if (fromCache) return;

    char sPlayerName[MAX_NAME_LENGTH];
    pUser.GetName(sPlayerName, sizeof(sPlayerName));

    char sSteamID2[32];
    pUser.GetSteamId2(sSteamID2, sizeof(sSteamID2));

    char sSteamID64[24];
    pUser.GetSteamId64(sSteamID64, sizeof(sSteamID64));

    char sIP[16];
    pUser.GetIPAddress(sIP, sizeof(sIP));

    char sSteamProfileURLPrefix[256];
    g_cSteamProfileURLPrefix.GetString(sSteamProfileURLPrefix, sizeof(sSteamProfileURLPrefix));
    char sIPDetailsURLPrefix[256];
    g_cIPDetailURLPrefix.GetString(sIPDetailsURLPrefix, sizeof(sIPDetailsURLPrefix));

    char sSteamProfileURL[256];
    Format(sSteamProfileURL, sizeof(sSteamProfileURL), "Steam Profile: %s%s", sSteamProfileURLPrefix, sSteamID64);

    char sIPLocationURL[256];
    Format(sIPLocationURL, sizeof(sIPLocationURL), "IP details: %s%s", sIPDetailsURLPrefix, sIP);

    char sTimeFormatted[64];
    char sTime[128];
    int iTime = GetTime();
    FormatTime(sTimeFormatted, sizeof(sTimeFormatted), "%m/%d/%Y @ %H:%M:%S", iTime);
    Format(sTime, sizeof(sTime), "Date: **%s**", sTimeFormatted);

    char sCurrentMap[PLATFORM_MAX_PATH];
    GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));

    char sWebhook[64];
    Format(sWebhook, sizeof(sWebhook), "proxykiller");

    char sMessage[4096];
    Format(sMessage, sizeof(sMessage), ">>> IP: %s\\nSteamID2: %s\\nPlayer name: %s\\n%s\\n%s\\nCurrent map: %s\\n%s", sIP, sSteamID2, sPlayerName, sSteamProfileURL, sIPDetailsURLPrefix, sCurrentMap, sTime);

    Discord_SendMessage(sWebhook, sMessage);
}
