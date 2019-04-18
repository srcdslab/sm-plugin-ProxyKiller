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

void DoCallback(Handle fwd, bool failure, const char[] response, any data = 0)
{
	if (fwd != null)
	{
		Call_StartForward(fwd);
		Call_PushCell(failure);
		Call_PushString(response);
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

bool EnsureDBDriver(const char[] conf, const char[] driver)
{
	char dbFilePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, dbFilePath, sizeof(dbFilePath), "configs\\databases.cfg");

	bool result = false;
	KeyValues kv = new KeyValues("Databases");

	kv.ImportFromFile(dbFilePath);
	bool confExists = kv.JumpToKey(conf);
	
	if (confExists)
	{
		char driverIdent[32];
		kv.GetString("driver", driverIdent, sizeof(driverIdent));
		result = StrEqual(driverIdent, driver, false);
	}
	
	delete kv;
	return result;
}

// =========================================================== //