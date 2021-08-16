// =========================================================== //

enum
{
	RuntimeVar_Name,
	RuntimeVar_UserId,
	RuntimeVar_IPAddress,
	RuntimeVar_SteamId2,
	RuntimeVar_SteamId64,
	RuntimeVar_COUNT
};

static char RuntimeVariables[RuntimeVar_COUNT][] =
{
	"{name}",
	"{userid}",
	"{ip}",
	"{steamid2}",
	"{steamid64}"
};

// =========================================================== //

/**
 * Takes a stringmap of (config) variables and performs expansions on |buffer|
 *
 * @param variables		StringMap of (config) variables available
 * @param buffer		Buffer from which variables will be expanded
 * @param maxlength		Maxlength of the buffer
 * @return				Number of expansions done on the buffer
 */
int ExpandConfigVariables(StringMap variables, char[] buffer, int maxlength)
{
	int totalExpands = 0;
	StringMapSnapshot vars = variables.Snapshot();

	for (int i = 0; i < vars.Length; i++)
	{
		char varName[MAX_CONFIG_VARIABLE_NAME];
		vars.GetKey(i, varName, sizeof(varName));

		char varValue[MAX_CONFIG_VARIABLE_VALUE];
		variables.GetString(varName, varValue, sizeof(varValue));

		Format(varName, sizeof(varName), "{{%s}}", varName);
		totalExpands += ReplaceString(buffer, maxlength, varName, varValue);
	}

	delete vars;
	return totalExpands;
}

/**
 * Takes a ProxyUser object and performs expansions on |buffer|
 *
 * @param pUser			ProxyUser object containing runtime variables
 * @param buffer		Buffer from which variables will be expanded
 * @param maxlength		Maxlength of the |buffer|
 * @return				Number of expansions done on the buffer
 */
int ExpandRuntimeVariables(ProxyUser pUser, char[] buffer, int maxlength)
{
	int totalExpands = 0;
	int userId = pUser.UserId;

	char name[MAX_NAME_LENGTH];
	pUser.GetName(name, sizeof(name));

	char ipAddr[24];
	pUser.GetIPAddress(ipAddr, sizeof(ipAddr));

	char steamId2[32];
	pUser.GetSteamId2(steamId2, sizeof(steamId2));

	char steamId64[24];
	pUser.GetSteamId64(steamId64, sizeof(steamId64));

	totalExpands += ExpandName(name, buffer, maxlength);
	totalExpands += ExpandUserId(userId, buffer, maxlength);
	totalExpands += ExpandIPAddress(ipAddr, buffer, maxlength);
	totalExpands += ExpandSteamId2(steamId2, buffer, maxlength);
	totalExpands += ExpandSteamId64(steamId64, buffer, maxlength);
	return totalExpands;
}

// =========================================================== //

/**
 * Expands name string template with the given |name|
 *
 * @param name			Name which will be used when expanding
 * @param buffer		Buffer from which name will be expanded
 * @param maxlength		Maxlength of the buffer
 * @return				Number of expansions done on the buffer
 */
int ExpandName(char[] name, char[] buffer, int maxlength)
{
	return ReplaceString(buffer, maxlength, RuntimeVariables[RuntimeVar_Name], name);
}

/**
 * Expands userid string template with the given |userId|
 *
 * @param userId		Userid which will be used when expanding
 * @param buffer		Buffer from which userid will be expanded
 * @param maxlength		Maxlength of the buffer
 * @return				Number of expansions done on the buffer
 */
int ExpandUserId(int userId, char[] buffer, int maxlength)
{
	char userIdStr[6];
	IntToString(userId, userIdStr, sizeof(userIdStr));
	return ReplaceString(buffer, maxlength, RuntimeVariables[RuntimeVar_UserId], userIdStr);
}

/**
 * Expands ip address string template with the given |ipAddress|
 *
 * @param ipAddress		Ip address which will be used when expanding
 * @param buffer		Buffer from which ip address will be expanded
 * @param maxlength		Maxlength of the buffer
 * @return				Number of expansions done on the buffer
 */
int ExpandIPAddress(char[] ipAddress, char[] buffer, int maxlength)
{
	return ReplaceString(buffer, maxlength, RuntimeVariables[RuntimeVar_IPAddress], ipAddress);
}

/**
 * Expands steamid2 string template with the given |steamId2|
 *
 * @param steamId2		Steamid2 which will be used when expanding
 * @param buffer		Buffer from which steamid2 will be expanded
 * @param maxlength		Maxlength of the buffer
 * @return				Number of expansions done on the buffer
 */
int ExpandSteamId2(char[] steamId2, char[] buffer, int maxlength)
{
	return ReplaceString(buffer, maxlength, RuntimeVariables[RuntimeVar_SteamId2], steamId2);
}

/**
 * Expands steamid64 string template with the given |steamId64|
 *
 * @param steamId64		Steamid64 which will be used when expanding
 * @param buffer		Buffer from which steamid64 will be expanded
 * @param maxlength		Maxlength of the buffer
 * @return				Number of expansions done on the buffer
 */
int ExpandSteamId64(char[] steamId64, char[] buffer, int maxlength)
{
	return ReplaceString(buffer, maxlength, RuntimeVariables[RuntimeVar_SteamId64], steamId64);
}

// =========================================================== //