// =========================================================== //

static bool ConfigInit = false;

#define DEFAULT_REQUEST_METHOD (HTTPMethod_GET)
#define DEFAULT_RESPONSE_TYPE (ResponseType_PLAINTEXT)
#define DEFAULT_RESPONSE_COMPARE (ResponseCompare_EQUAL)

// =========================================================== //

static char MethodPhrases[HTTPMethod_COUNT][] =
{
    "GET",
    "HEAD",
    "POST",
    "PUT",
    "DELETE",
    "OPTIONS",
    "PATCH"
};

static char TypePhrases[ResponseType_COUNT][] =
{
	"json",
	"plaintext",
	"statuscode"
};

static char ComparePhrases[ResponseCompare_COUNT][] =
{
	"equal",
	"notequal"
};

// =========================================================== //

bool IsConfigInit()
{
	return ConfigInit;
}

ProxyConfig ParseConfig(char[] configFile)
{
	g_Logger.PrintFrame();

	if (!FileExists(configFile))
	{
		SetFailState("%s does not exist!", configFile);
	}

	KeyValues config = new KeyValues(PROXYKILLER_NAME);
	if (!config.ImportFromFile(configFile))
	{
		SetFailState("Failed parsing %s!", configFile);
	}

	StringMap variables = new StringMap();
	while (config.GotoFirstSubKey(false) || config.GotoNextKey(false))
	{
		// We only want keys on root node
		if (config.NodesInStack() > 1)
		{
			continue;
		}

		char key[MAX_CONFIG_VARIABLE_NAME];
		config.GetSectionName(key, sizeof(key));

		if (config.GetDataType(NULL_STRING) == KvData_String)
		{
			char value[MAX_CONFIG_VARIABLE_VALUE];
			config.GetString(NULL_STRING, value, sizeof(value));

			ExpandConfigVariables(variables, value, sizeof(value));
			variables.SetString(key, value);
		}
	}

	// Go back!
	config.Rewind();

	if (!config.GotoFirstSubKey(true))
	{
		SetFailState("No service configured!");
	}

	// Traverse a potential service
	char name[MAX_SERVICE_NAME_LENGTH];
	config.GetSectionName(name, sizeof(name));

	char url[MAX_HTTP_URL_LENGTH];
	config.GetString("url", url, sizeof(url));

	char method[10];
	config.GetString("method", method, sizeof(method));

	ProxyServiceResponse response = ParseResponse(config);
	if (response == null)
	{
		SetFailState("Service response not configured!");
	}

	config.Rewind();
	config.JumpToKey(name);

	ProxyHTTPMethod httpMethod = GetHTTPMethodFromString(method);
	ProxyService service = new ProxyService(url, httpMethod, name, response);

	ParseAndSetParams(config, service, variables);
	config.Rewind();
	config.JumpToKey(name);

	ParseAndSetHeaders(config, service, variables);
	config.Rewind();
	config.JumpToKey(name);

	delete config;
	ConfigInit = true;
	return new ProxyConfig(variables, service);
}

int ParseAndSetParams(KeyValues config, ProxyService service, StringMap vars)
{
	int addedParamsCount = 0;
	if (config.JumpToKey("params"))
	{
		while (config.GotoFirstSubKey(false) || config.GotoNextKey(false))
		{
			char paramName[MAX_PARAM_NAME_LENGTH];
			config.GetSectionName(paramName, sizeof(paramName));

			char paramValue[MAX_PARAM_VALUE_LENGTH];
			config.GetString(NULL_STRING, paramValue, sizeof(paramValue));

			ExpandConfigVariables(vars, paramValue, sizeof(paramValue));

			addedParamsCount++;
			service.Params.AddParam(paramName, paramValue);
			g_Logger.DebugMessage("Parsed param \"%s\" = \"%s\"", paramName, paramValue);
		}
	}

	return addedParamsCount;
}

int ParseAndSetHeaders(KeyValues config, ProxyService service, StringMap vars)
{
	int addedHeadersCount = 0;
	if (config.JumpToKey("headers"))
	{
		while (config.GotoFirstSubKey(false) || config.GotoNextKey(false))
		{
			char headerName[MAX_HEADER_NAME_LENGTH];
			config.GetSectionName(headerName, sizeof(headerName));

			char headerValue[MAX_HEADER_VALUE_LENGTH];
			config.GetString(NULL_STRING, headerValue, sizeof(headerValue));

			ExpandConfigVariables(vars, headerValue, sizeof(headerValue));

			addedHeadersCount++;
			service.Headers.AddHeader(headerName, headerValue);
			g_Logger.DebugMessage("Parsed header \"%s\" = \"%s\"", headerName, headerValue);
		}
	}

	return addedHeadersCount;
}

ProxyServiceResponse ParseResponse(KeyValues config)
{
	if (config.JumpToKey("response"))
	{
		char responseType[MAX_RESPONSE_TYPE_LENGTH];
		config.GetString("type", responseType, sizeof(responseType));

		char responseValue[MAX_RESPONSE_VALUE_LENGTH];
		config.GetString("value", responseValue, sizeof(responseValue));

		char responseObject[MAX_RESPONSE_OBJECT_LENGTH];
		config.GetString("object", responseObject, sizeof(responseObject));

		char responseCompare[MAX_RESPONSE_COMPARE_LENGTH];
		config.GetString("compare", responseCompare, sizeof(responseCompare));

		ResponseType type = GetResponseTypeFromString(responseType);
		ResponseCompare compare = GetResponseCompareFromString(responseCompare);

		return new ProxyServiceResponse(type, compare, responseValue, responseObject);
	}

	return null;
}

// =========================================================== //

ProxyHTTPMethod GetHTTPMethodFromString(char[] str, bool caseSensitive = false)
{
	for (ProxyHTTPMethod i; i < HTTPMethod_COUNT; i++)
	{
		if (StrEqual(str, MethodPhrases[i], caseSensitive))
		{
			return i;
		}
	}

	return DEFAULT_REQUEST_METHOD;
}

ResponseType GetResponseTypeFromString(char[] str, bool caseSensitive = false)
{
	for (ResponseType i; i < ResponseType_COUNT; i++)
	{
		if (StrEqual(str, TypePhrases[i], caseSensitive))
		{
			return i;
		}
	}

	return DEFAULT_RESPONSE_TYPE;
}

ResponseCompare GetResponseCompareFromString(char[] str, bool caseSensitive = false)
{
	for (ResponseCompare i; i < ResponseCompare_COUNT; i++)
	{
		if (StrEqual(str, ComparePhrases[i], caseSensitive))
		{
			return i;
		}
	}

	return DEFAULT_RESPONSE_COMPARE;
}

// =========================================================== //