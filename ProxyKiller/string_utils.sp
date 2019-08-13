// =========================================================== //

enum
{
	RuntimeVar_UserId = 0,
	RuntimeVar_IPAddress,
	RuntimeVar_SteamId2,
	RuntimeVar_COUNT
};

static char RuntimeVariables[RuntimeVar_COUNT][] =
{
	"{userid}",
	"{ip}",
	"{steamid2}"
};

// =========================================================== //

int ExpandConfigVariables(StringMap variables, char[] buffer, int maxlength)
{
	int totalExpands = 0;
	StringMapSnapshot vars = variables.Snapshot();

	for (int i = 0; i < vars.Length; i++)
	{
		char varName[128];
		vars.GetKey(i, varName, sizeof(varName));
		
		char varValue[256];
		variables.GetString(varName, varValue, sizeof(varValue));

		Format(varName, sizeof(varName), "{{%s}}", varName);
		totalExpands += ReplaceString(buffer, maxlength, varName, varValue);
	}

	delete vars;
	return totalExpands;
}

int ExpandRuntimeVariables(ProxyUser pUser, char[] buffer, int maxlength)
{
	int totalExpands = 0;
	int userId = pUser.UserId;

	char ipAddr[24];
	pUser.GetIPAddress(ipAddr, sizeof(ipAddr));

	char steamId2[32];
	pUser.GetSteamId2(steamId2, sizeof(steamId2));

	totalExpands += ExpandUserId(userId, buffer, maxlength);
	totalExpands += ExpandIPAddress(ipAddr, buffer, maxlength);
	totalExpands += ExpandSteamId2(steamId2, buffer, maxlength);
	return totalExpands;
}

// =========================================================== //

int ExpandUserId(int userId, char[] buffer, int maxlength)
{
	char userIdStr[6];
	IntToString(userId, userIdStr, sizeof(userIdStr));
	return ReplaceString(buffer, maxlength, RuntimeVariables[RuntimeVar_UserId], userIdStr);
}

int ExpandIPAddress(char[] ipAddress, char[] buffer, int maxlength)
{
	return ReplaceString(buffer, maxlength, RuntimeVariables[RuntimeVar_IPAddress], ipAddress);
}

int ExpandSteamId2(char[] steamId2, char[] buffer, int maxlength)
{
	return ReplaceString(buffer, maxlength, RuntimeVariables[RuntimeVar_SteamId2], steamId2);
}

// =========================================================== //