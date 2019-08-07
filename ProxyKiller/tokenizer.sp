// =========================================================== //

#define IP_TOKEN "{ip}"
#define USERID_TOKEN "{userid}"
#define STEAMID2_TOKEN "{steamid2}"

// =========================================================== //

void TokenizeAll(ProxyUser pUser, char[] buffer, int maxlength)
{
	int userId = pUser.UserId;

	char ipAddr[24];
	pUser.GetIPAddress(ipAddr, sizeof(ipAddr));

	char steamId2[32];
	pUser.GetSteamId2(steamId2, sizeof(steamId2));

	TokenizeIP(ipAddr, buffer, maxlength);
	TokenizeUserId(userId, buffer, maxlength);
	TokenizeSteamId2(steamId2, buffer, maxlength);
}

// =========================================================== //

void TokenizeIP(char[] ipAddress, char[] buffer, int maxlength)
{
	ReplaceString(buffer, maxlength, IP_TOKEN, ipAddress);
}

void TokenizeUserId(int userId, char[] buffer, int maxlength)
{
	char userIdStr[6];
	IntToString(userId, userIdStr, sizeof(userIdStr));
	ReplaceString(buffer, maxlength, USERID_TOKEN, userIdStr);
}

void TokenizeSteamId2(char[] steamId2, char[] buffer, int maxlength)
{
	ReplaceString(buffer, maxlength, STEAMID2_TOKEN, steamId2);
}

// =========================================================== //