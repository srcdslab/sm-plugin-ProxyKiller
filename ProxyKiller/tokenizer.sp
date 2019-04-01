// =========================================================== //

#define IP_TOKEN "{ip}"
#define STEAMID2_TOKEN "{steamid2}"

// =========================================================== //

void TokenizeAll(ProxyUser pUser, char[] buffer, int maxlength)
{
	char ipAddress[24];
	pUser.GetIPAddress(ipAddress, sizeof(ipAddress));
	TokenizeIP(ipAddress, buffer, maxlength);
	
	char steamId2[32];
	pUser.GetSteamId2(steamId2, sizeof(steamId2));
	TokenizeSteamId2(steamId2, buffer, maxlength);
}

// =========================================================== //

void TokenizeIP(char[] ipAddress, char[] buffer, int maxlength)
{
	ReplaceString(buffer, maxlength, IP_TOKEN, ipAddress);
}

void TokenizeSteamId2(char[] steamId2, char[] buffer, int maxlength)
{
	ReplaceString(buffer, maxlength, STEAMID2_TOKEN, steamId2);
}

// =========================================================== //