#include <sourcemod>
#include <ProxyKiller>
#include <discordWebhookAPI>

#pragma newdecls required

ConVar g_cSteamProfileURLPrefix, g_cIPDetailURLPrefix, g_cCountBots;
ConVar g_cvWebhook;

public Plugin myinfo = 
{
    name = "ProxyKillerDiscord",
    author = "maxime1907, Sikari, .Rushaway",
    description = "Sends detected vpn players info to discord",
    version = "1.1.0",
    url = ""
};

public void OnPluginStart()
{
    g_cSteamProfileURLPrefix = CreateConVar("sm_proxykiller_discord_steam_profile_url", "https://steamcommunity.com/profiles/", "URL of the steam profile");
    g_cIPDetailURLPrefix = CreateConVar("sm_proxykiller_discord_ip_details_url", "http://geoiplookup.net/ip/", "URL of the website that analyses the IP");
    g_cCountBots = CreateConVar("sm_proxykiller_discord_count_bots", "1", "Should we count bots as players ?[0 = No, 1 = Yes]", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvWebhook = CreateConVar("sm_proxykiller_discord_webhook", "", "The webhook URL of your Discord channel.", FCVAR_PROTECTED);

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
    Format(sSteamProfileURL, sizeof(sSteamProfileURL), "**Steam Profile :** %s%s", sSteamProfileURLPrefix, sSteamID64);

    char sIPLocationURL[256];
    Format(sIPLocationURL, sizeof(sIPLocationURL), "**IP Details :** %s%s", sIPDetailsURLPrefix, sIP);

    char sTimeFormatted[64];
    char sTime[128];
    int iTime = GetTime();
    FormatTime(sTimeFormatted, sizeof(sTimeFormatted), "%d/%m/%Y @ %H:%M:%S", iTime);
    Format(sTime, sizeof(sTime), "Date : %s", sTimeFormatted);

    char sCurrentMap[PLATFORM_MAX_PATH];
    GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));

    char sCount[64];
    int iMaxPlayers = MaxClients;
    int iConnected = GetClientCountEx(g_cCountBots.BoolValue);
    Format(sCount, sizeof(sCount), "Players : %d/%d", iConnected, iMaxPlayers);

    char sPluginVersion[256];
    GetPluginInfo(INVALID_HANDLE, PlInfo_Version, sPluginVersion, sizeof(sPluginVersion));

    char sMessage[4096];
    Format(sMessage, sizeof(sMessage), "```%s [%s] \nDetected IP : %s \nCurrent map : %s \n%s \n%s \nV.%s```%s \n%s", sPlayerName, sSteamID2, sIP, sCurrentMap, sTime, sCount, sPluginVersion, sSteamProfileURL, sIPLocationURL);
    ReplaceString(sMessage, sizeof(sMessage), "\\n", "\n");

    char szWebhookURL[1000];
    g_cvWebhook.GetString(szWebhookURL, sizeof szWebhookURL);

    Webhook webhook = new Webhook(sMessage);
    webhook.Execute(szWebhookURL, OnWebHookExecuted);
    delete webhook;
}

public void OnWebHookExecuted(HTTPResponse response, DataPack pack)
{
    if (response.Status != HTTPStatus_OK)
    {
        LogError("Failed to send proxykiller webhook");
    }
}

stock int GetClientCountEx(bool countBots)
{
	int iRealClients = 0;
	int iFakeClients = 0;

	for(int player = 1; player <= MaxClients; player++)
	{
		if(IsClientConnected(player))
		{
			if(IsFakeClient(player))
				iFakeClients++;
			else
				iRealClients++;
		}
	}
	return countBots ? iFakeClients + iRealClients : iRealClients;
}