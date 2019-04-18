// =========================================================== //

#define DEFAULT_CONFIG "cfg/sourcemod/ProxyKiller-Config.cfg"

// =========================================================== //

ProxyService ParseConfig(char[] configFile)
{
	if (!FileExists(configFile))
	{
		SetFailState("%s does not exist!", configFile);
	}

	KeyValues config = new KeyValues("ProxyKiller");

	if (!config.ImportFromFile(configFile) || !config.GotoFirstSubKey())
	{
		SetFailState("Failed parsing %s!", configFile);
	}

	char name[MAX_SERVICE_NAME_LENGTH];
	config.GetSectionName(name, sizeof(name));
		
	char url[MAX_URL_LENGTH];
	config.GetString("url", url, sizeof(url));
	
	char method[12];
	config.GetString("method", method, sizeof(method));
		
	ProxyService service = new ProxyService();
	service.SetUrl(url);
	service.SetName(name);

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
		ProxyHTTPParams params = new ProxyHTTPParams();
			
		while (config.GotoFirstSubKey(false) || config.GotoNextKey(false))
		{
			char paramName[MAX_PARAM_NAME_LENGTH];
			config.GetSectionName(paramName, sizeof(paramName));
				
			char paramValue[MAX_PARAM_VALUE_LENGTH];
			config.GetString(NULL_STRING, paramValue, sizeof(paramValue));
				
			params.AddParam(paramName, paramValue);
		}
			
		config.Rewind();
		config.JumpToKey(name);
		service.Params = params;
	}
		
	if (config.JumpToKey("headers"))
	{
		ProxyHTTPHeaders headers = new ProxyHTTPHeaders();
			
		while (config.GotoFirstSubKey(false) || config.GotoNextKey(false))
		{
			char headerName[MAX_HEADER_NAME_LENGTH];
			config.GetSectionName(headerName, sizeof(headerName));
				
			char headerValue[MAX_HEADER_VALUE_LENGTH];
			config.GetString(NULL_STRING, headerValue, sizeof(headerValue));
				
			headers.AddHeader(headerName, headerValue);
		}
			
		config.Rewind();
		config.JumpToKey(name);
		service.Headers = headers;
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
		config.JumpToKey(name);
		service.Response = response;
	}

	delete config;
	return service;
}

// =========================================================== //