// =========================================================== //

#define DEFAULT_CONFIG "cfg/sourcemod/ProxyKiller-Config.cfg"

// =========================================================== //

void ParseConfig(char[] configFile, ProxyServices destList)
{
	destList.Clear();

	if (!FileExists(configFile))
	{
		SetFailState("%s does not exist!", configFile);
	}

	KeyValues config = new KeyValues("ProxyKiller");

	if (!config.ImportFromFile(configFile) || !config.GotoFirstSubKey())
	{
		SetFailState("Failed parsing %s!", configFile);
	}

	do
	{
		char name[MAX_SERVICE_NAME_LENGTH];
		config.GetSectionName(name, sizeof(name));
		
		char url[MAX_URL_LENGTH];
		config.GetString("url", url, sizeof(url));
		
		char token[MAX_TOKEN_NAME_LENGTH];
		config.GetString("token", token, sizeof(token), "__undefined");
		
		char tokenValue[MAX_TOKEN_VALUE_LENGTH];
		config.GetString("tokenValue", tokenValue, sizeof(tokenValue), "__undefined");
		
		ProxyService service = new ProxyService();
		service.SetUrl(url);
		service.SetName(name);
		service.SetToken(token);
		service.SetTokenValue(tokenValue);
		
		if (config.JumpToKey("params"))
		{
			ProxyServiceParams params = new ProxyServiceParams();
			
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
		
		destList.AddService(service);
		
	} while (config.GotoNextKey());
	
	delete config;
}

// =========================================================== //