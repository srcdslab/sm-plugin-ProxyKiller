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