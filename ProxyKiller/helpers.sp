// =========================================================== //

bool KickClientSafe(int client)
{
	if (client <= 0 || !IsClientConnected(client))
	{
		return false;
	}
	else
	{
		char kickMsg[KICK_MESSAGE_LENGTH];
		gCV_KickMsg.GetString(kickMsg, sizeof(kickMsg));

		KickClient(client, "%s", kickMsg);
		return true;
	}
}

bool HasApp(int client, int appid)
{
	return (SteamWorks_HasLicenseForApp(client, appid) == k_EUserHasLicenseResultHasLicense);
}

bool HasAppFrom(int client, char[] appString)
{
	char appIds[16][16];
	int appCount = ExplodeString(appString, ",", appIds, sizeof(appIds), sizeof(appIds[]));
	
	for (int i = 0; i < appCount; i++)
	{
		if (HasApp(client, StringToInt(appIds[i])))
		{
			return true;
		}
	}
	
	return false;
}

EHTTPMethod GetSteamWorksMethod(ProxyHTTPMethod method)
{
	switch (method)
	{
		case HTTPMethod_GET: return k_EHTTPMethodGET;
		case HTTPMethod_POST: return k_EHTTPMethodPOST;
	}

	return k_EHTTPMethodGET;
}

void DoCallback(Handle fwd, ProxyHTTPResponse response, const char[] responseData, any data = 0)
{
	if (fwd != null)
	{
		Call_StartForward(fwd);
		Call_PushCell(response);
		Call_PushString(responseData);
		Call_PushCell(data);
		Call_Finish();
	}
}

JSON_Object GetObjectSafe(JSON_Object obj, char[] key = "", int index = -1)
{
	if (obj == null || (key[0] == '\0' && index == -1))
	{
		return null;
	}
	else if (index == -1)
	{
		return obj.GetObject(key);
	}
	else
	{
		return obj.GetObjectIndexed(index);
	}
}

// =========================================================== //