// =========================================================== //

void DoPunishment(ProxyUser pUser, bool fromCache)
{
	char log[MAX_PUNISHMENT_LOG_LENGTH];
	gCV_PunishmentLogFormat.GetString(log, sizeof(log));

	if (!StrEqual(log, ""))
	{
		ExpandRuntimeVariables(pUser, log, sizeof(log));
		g_Logger.InfoMessage("%s", log);
	}

	int client = GetClientOfUserId(pUser.UserId);
	if (client > 0 && IsClientConnected(client))
	{
		char msg[MAX_PUNISHMENT_MESSAGE_LENGTH];
		gCV_PunishmentMessage.GetString(msg, sizeof(msg));

		int punishType = gCV_PunishmentType.IntValue;
		if (punishType == Punishment_Kick)
		{
			ExpandRuntimeVariables(pUser, msg, sizeof(msg));
			KickClient(client, "%s", msg);
		}
		else if (punishType == Punishment_Ban)
		{
			ExpandRuntimeVariables(pUser, msg, sizeof(msg));

			int banLength = gCV_PunishmentBanLength.IntValue;
			BanClient(client, banLength, BANFLAG_AUTO, msg, msg);
		}
	}

	Call_OnClientPunishment(pUser, fromCache);
}

bool HasOverride(int client)
{
	return (HasFlag(client, ADMFLAG_ROOT));
}

bool HasFlag(int client, int flag)
{
	return (CheckCommandAccess(client, "ProxyKiller_Bypass", flag));
}

bool HasApp(int client, int appid)
{
	return (SteamWorks_HasLicenseForApp(client, appid) == k_EUserHasLicenseResultHasLicense);
}

bool HasFlagFromFlagString(int client, char[] flagString)
{
	int bitString = ReadFlagString(flagString);

	AdminFlag flags[AdminFlags_TOTAL];
	int flagCount = FlagBitsToArray(bitString, flags, sizeof(flags));

	for (int i = 0; i < flagCount; i++)
	{
		if (HasFlag(client, FlagToBit(flags[i])))
		{
			return true;
		}
	}

	return false;
}

bool HasAppFromAppString(int client, char[] appString)
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
		case HTTPMethod_HEAD: return k_EHTTPMethodHEAD;
		case HTTPMethod_POST: return k_EHTTPMethodPOST;
		case HTTPMethod_PUT: return k_EHTTPMethodPUT;
		case HTTPMethod_DELETE: return k_EHTTPMethodDELETE;
		case HTTPMethod_OPTIONS: return k_EHTTPMethodOPTIONS;
		case HTTPMethod_PATCH: return k_EHTTPMethodPATCH;
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
		char sKey[1024];
		obj.GetKey(index, sKey, sizeof(sKey))
		return obj.GetObject(sKey);
	}
}

// =========================================================== //