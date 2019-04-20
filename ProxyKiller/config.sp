// =========================================================== //

ProxyConfig ParseConfig(char[] configFile)
{
	if (!FileExists(configFile))
	{
		SetFailState("%s does not exist!", configFile);
	}

	KeyValues config = new KeyValues(PROXYKILLER_NAME);

	if (!config.ImportFromFile(configFile))
	{
		SetFailState("Failed parsing %s!", configFile);
	}

	// Get values inside the root node
	StringMap cachedVars = new StringMap();
	while (config.GotoFirstSubKey(false) || config.GotoFirstSubKey(false))
	{
		char key[64];
		config.GetSectionName(key, sizeof(key));
		
		char value[256];
		config.GetString(NULL_STRING, value, sizeof(value));

		cachedVars.SetString(key, value);
	}

	// Go back!
	config.Rewind();

	if (!config.GotoFirstSubKey())
	{
		SetFailState("No service configured!");
	}

	// Traverse a potential service
	char name[MAX_SERVICE_NAME_LENGTH];
	config.GetSectionName(name, sizeof(name));

	char url[MAX_URL_LENGTH];
	config.GetString("url", url, sizeof(url));

	char method[12];
	config.GetString("method", method, sizeof(method));

	ProxyService service = new ProxyService();
	service.SetUrl(url);
	service.SetName(name);

	// TODO: Bad
	if (StrEqual(method, "GET", false))
	{
		service.Method = k_EHTTPMethodGET;
	}
	else if (StrEqual(method, "POST", false))
	{
		service.Method = k_EHTTPMethodPOST;
	}

	if (config.JumpToKey("params"))
	{
		while (config.GotoFirstSubKey(false) || config.GotoNextKey(false))
		{
			char paramName[MAX_PARAM_NAME_LENGTH];
			config.GetSectionName(paramName, sizeof(paramName));

			char paramValue[MAX_PARAM_VALUE_LENGTH];
			config.GetString(NULL_STRING, paramValue, sizeof(paramValue));

			char tokenName[MAX_PARAM_VALUE_LENGTH];
			if (GetTokenFromInput(paramValue, tokenName, sizeof(tokenName)))
			{
				if (!cachedVars.GetString(tokenName, paramValue, sizeof(paramValue)))
				{
					LogError("Token \"%s\" does not exist in the root node!", tokenName);
				}
			}

			service.Params.AddParam(paramName, paramValue);
		}

		config.Rewind();
		config.JumpToKey(name);
	}

	if (config.JumpToKey("headers"))
	{
		while (config.GotoFirstSubKey(false) || config.GotoNextKey(false))
		{
			char headerName[MAX_HEADER_NAME_LENGTH];
			config.GetSectionName(headerName, sizeof(headerName));

			char headerValue[MAX_HEADER_VALUE_LENGTH];
			config.GetString(NULL_STRING, headerValue, sizeof(headerValue));

			char tokenName[MAX_HEADER_VALUE_LENGTH];
			if (GetTokenFromInput(headerValue, tokenName, sizeof(tokenName)))
			{
				if (!cachedVars.GetString(tokenName, headerValue, sizeof(headerValue)))
				{
					LogError("Token \"%s\" does not exist in the root node!", tokenName);
				}
			}

			service.Headers.AddHeader(headerName, headerValue);
		}

		config.Rewind();
		config.JumpToKey(name);
	}

	if (config.JumpToKey("response"))
	{
		ProxyServiceResponse response = new ProxyServiceResponse();

		char responseType[MAX_RESPONSE_TYPE_LENGTH];
		config.GetString("type", responseType, sizeof(responseType));

		char responseStr[MAX_RESPONSE_NAME_LENGTH + MAX_RESPONSE_VALUE_LENGTH];
		config.GetString("expect", responseStr, sizeof(responseStr));

		response.SetType(responseType);

		char tokens[2][MAX_RESPONSE_VALUE_LENGTH];
		if (ExplodeString(responseStr, "==", tokens, sizeof(tokens), sizeof(tokens[])) >= 2)
		{
			response.Compare = RC_EQUAL;
		}
		else if (ExplodeString(responseStr, "!=", tokens, sizeof(tokens), sizeof(tokens[])) >= 2)
		{
			response.Compare = RC_NOTEQUAL;
		}

		TrimString(tokens[0]);

		if (response.Type == RT_JSON)
		{
			TrimString(tokens[1]);
			response.SetValue(tokens[1]);
			response.SetObject(tokens[0]);
		}
		else
		{
			response.SetValue(tokens[0]); 
		}

		config.Rewind();
		service.Response = response;
	}
	
	delete config;
	return new ProxyConfig(cachedVars, service);
}

// TODO: not really good way of doing this
bool GetTokenFromInput(char[] input, char[] buffer, int maxlength)
{
	int charsLen = strlen("{{}}") / 2;
	int start = StrContains(input, "{{");
	int end = StrContains(input[start + charsLen], "}}");

	if (start != -1 && end != -1 && end > start)
	{
		buffer[0] = '\0';
		start = start + charsLen;
		end = end + charsLen;
		
		for (int i = start; i < end; i++)
		{
			Format(buffer, maxlength, "%s%c", buffer, input[i]);
		}
		
		return true;
	}
	
	return false;
}

// =========================================================== //