// =========================================================== //

void QueryServices(char[] ipAddress, char[] steamId)
{
	for (int i = 0; i < g_Services.Length; i++)
	{
		ProxyService service = g_Services.Get(i);

		char url[MAX_URL_LENGTH];
		service.GetUrl(url, sizeof(url));

		ReplaceIP(ipAddress, url, sizeof(url));
		Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, url);

		if (request == null)
		{
			delete request;
			continue;
		}

		StringMapSnapshot params = service.Params.Snapshot();

		for (int x = 0; x < params.Length; x++)
		{
			char paramName[MAX_PARAM_NAME_LENGTH];
			params.GetKey(x, paramName, sizeof(paramName));
			
			if (!json_is_meta_key(paramName))
			{
				char paramValue[MAX_PARAM_VALUE_LENGTH];
				service.Params.GetString(paramName, paramValue, sizeof(paramValue));

				ReplaceIP(ipAddress, paramValue, sizeof(paramValue));
				SteamWorks_SetHTTPRequestGetOrPostParameter(request, paramName, paramValue);
			}
		}

		DataPack data = new DataPack();
		data.WriteCell(service);
		data.WriteString(ipAddress);
		data.WriteString(steamId);

		SteamWorks_SetHTTPCallbacks(request, OnRequest_Completed, _, OnRequest_DataReceived);
		SteamWorks_SetHTTPRequestContextValue(request, data);
		SteamWorks_SendHTTPRequest(request);
		delete params;
	}
}

// =========================================================== //

public int OnRequest_Completed(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, DataPack data)
{
	if (failure || !requestSuccessful)
	{
		data.Reset();
		ProxyService service = data.ReadCell();

		char ipAddress[24];
		data.ReadString(ipAddress, sizeof(ipAddress));
		
		char steamId[32];
		data.ReadString(steamId, sizeof(steamId));
		delete data;
		
		char serviceName[MAX_SERVICE_NAME_LENGTH];
		service.GetName(serviceName, sizeof(serviceName));
		
		g_Logger.LogLine("HTTP failure %d! - IP: %s - SteamId: %s - Service: %s", statusCode, ipAddress, steamId, serviceName);
	}
}

public int OnRequest_DataReceived(Handle request, bool failure, int offset, int bytesReceived, DataPack data)
{
	if (!failure && request != null)
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnRequest_Data, data);
	}

	delete request;
}

public int OnRequest_Data(const char[] response, DataPack data)
{
	data.Reset();
	ProxyService service = data.ReadCell();

	char ipAddress[24];
	data.ReadString(ipAddress, sizeof(ipAddress));

	char steamId[32];
	data.ReadString(steamId, sizeof(steamId));
	delete data;

	char token[MAX_TOKEN_NAME_LENGTH];
	service.GetToken(token, sizeof(token));
	
	char objs[32][MAX_TOKEN_NAME_LENGTH];
	int objCount = ExplodeString(token, ".", objs, sizeof(objs), sizeof(objs[]));

	char responseValue[MAX_TOKEN_VALUE_LENGTH];
	JSON_Object currentObj = json_decode(response);
	JSON_Object originalPtr = currentObj;

	for (int i = 0; i < objCount; i++)
	{
		ReplaceIP(ipAddress, objs[i], sizeof(objs[]));

		if (i < objCount - 1)
		{
			int arrayStart = FindCharInString(objs[i], '[', true);
			int arrayEnding = FindCharInString(objs[i], ']', true);

			if (arrayEnding > arrayStart + 1)
			{
				int maxlength = arrayEnding - arrayStart;
				char[] indexString = new char[maxlength];
				
				char[] objArrayless = new char[arrayStart + 1];
				Format(objArrayless, arrayStart + 1, "%s", objs[i]);
				Format(indexString, maxlength, "%s", objs[i][arrayStart + 1]);
				
				currentObj = GetObjectSafe(currentObj, objArrayless);
				currentObj = GetObjectSafe(currentObj, _, StringToInt(indexString));
			}
			else
			{
				currentObj = GetObjectSafe(currentObj, objs[i]);
			}
		}
		else
		{
			if (currentObj != null)
			{
				currentObj.GetString(objs[i], responseValue, sizeof(responseValue));
			}
		}
	}

	char tokenValue[MAX_TOKEN_VALUE_LENGTH];
	service.GetTokenValue(tokenValue, sizeof(tokenValue));

	bool shouldBlock = StrEqual(responseValue, tokenValue);
	g_cacheLayer.AddEntry(ipAddress, shouldBlock, OnEntry);

	if (shouldBlock)
	{
		KickClientsByIp(ipAddress);
		g_Logger.LogLine("Kicked IP %s [%s] due to proxy! (Fresh)", ipAddress, steamId);
	}

	if (originalPtr != null)
	{
		originalPtr.Cleanup();
		delete originalPtr;
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