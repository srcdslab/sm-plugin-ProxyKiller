// =========================================================== //

#define MAX_USERS_IN_LIST_FILE 1000

char g_sUserAuthWhitelist[MAX_USERS_IN_LIST_FILE][MAX_AUTHID_LENGTH];
char g_sUserAuthBlacklist[MAX_USERS_IN_LIST_FILE][MAX_AUTHID_LENGTH];

static bool WhitelistInit = false;
static bool BlacklistInit = false;

// =========================================================== //

void CreateLists()
{
	CreateWhitelist(PROXYKILLER_WHITELIST);
	CreateBlacklist(PROXYKILLER_BLACKLIST);
}

bool IsWhitelistInit()
{
	return WhitelistInit;
}

bool IsBlacklistInit()
{
	return BlacklistInit;
}

bool IsUserWhitelisted(int client)
{
	return CheckUserInLists(client, false);
}

bool IsUserBlacklisted(int client)
{
	return CheckUserInLists(client, true);
}
 
bool CheckUserInLists(int client, bool blacklist = false)
{
	static char sSteamID2[MAX_AUTHID_LENGTH];
	if (!GetClientAuthId(client, AuthId_Steam2, sSteamID2, sizeof(sSteamID2), false))
		return false;

	if (!blacklist)
	{
		for (int i = 0; i <= (MAX_USERS_IN_LIST_FILE - 1); i++)
		{
			if (strcmp(sSteamID2, g_sUserAuthWhitelist[i], false) == 0)
				return true;
		}
	}
	else
	{
		for (int i = 0; i <= (MAX_USERS_IN_LIST_FILE - 1); i++)
		{
			if (strcmp(sSteamID2, g_sUserAuthBlacklist[i], false) == 0)
				return true;
		}
	}
	return false;
}

void LoadWhitelist()
{
	ReadLists(false);
}

void LoadBlacklist()
{
	ReadLists(true);
}

void ReadLists(bool blacklist = false)
{
	char sDataFile[PLATFORM_MAX_PATH];
	if (!blacklist)
	{
		FormatEx(sDataFile, sizeof(sDataFile), PROXYKILLER_WHITELIST);
		for (int i = 0; i <= (MAX_USERS_IN_LIST_FILE - 1); i++)
			g_sUserAuthWhitelist[i] = "\0";
	}
	else
	{
		FormatEx(sDataFile, sizeof(sDataFile), PROXYKILLER_BLACKLIST);
		for (int i = 0; i <= (MAX_USERS_IN_LIST_FILE - 1); i++)
			g_sUserAuthBlacklist[i] = "\0";
	}

	File fFile = OpenFile(sDataFile, "rt");
	if (!fFile)
	{
		LogError("Could not read from: %s", sDataFile);
		return;
	}

	if (!blacklist)
		WhitelistInit = true;
	else
		BlacklistInit = true;

	char sAuth[MAX_AUTHID_LENGTH];
	int iIndex = 0;

	while (!fFile.EndOfFile())
	{
		char line[512];
		if (!fFile.ReadLine(line, sizeof(line)))
			break;

		/* Trim comments */
		int len = strlen(line);
		bool ignoring = false;
		for (int i=0; i<len; i++)
		{
			if (ignoring)
			{
				if (line[i] == '"')
					ignoring = false;
			}
			else
			{
				if (line[i] == '"')
				{
					ignoring = true;
				}
				else if (line[i] == ';')
				{
					line[i] = '\0';
					break;
				}
				else if (line[i] == '/' && i != len - 1 && line[i+1] == '/')
				{
					line[i] = '\0';
					break;
				}
			}
		}

		TrimString(line);

		if ((line[0] == '/' && line[1] == '/') || (line[0] == ';' || line[0] == '\0'))
			continue;

		sAuth = "";
		BreakString(line, sAuth, sizeof(sAuth));
		if (!blacklist)
			g_sUserAuthWhitelist[iIndex] = sAuth;
		else
			g_sUserAuthBlacklist[iIndex] = sAuth;
		iIndex ++;
	}
	fFile.Close();
}

void CreateWhitelist(const char[] sWhitelist)
{
	char sWhitelistPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sWhitelistPath, sizeof(sWhitelistPath), sWhitelist);

	if (!FileExists(sWhitelist))
		SetFailState("%s does not exist!", sWhitelist);
}

void CreateBlacklist(const char[] sBlacklist)
{
	char sBlacklistPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sBlacklistPath, sizeof(sBlacklistPath), sBlacklist);

	if (!FileExists(sBlacklist))
		SetFailState("%s does not exist!", sBlacklist);
}

// =========================================================== //