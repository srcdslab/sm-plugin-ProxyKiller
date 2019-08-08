// =========================================================== //

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

	StringMap cachedVars = new StringMap();
	while (config.GotoFirstSubKey(false) || config.GotoNextKey(false))
	{
		// We only want keys on root node
		if (config.NodesInStack() > 1)
		{
			continue;
		}

		char key[64];
		config.GetSectionName(key, sizeof(key));

		char value[256];
		config.GetString(NULL_STRING, value, sizeof(value));

		if (!StrEqual(value, ""))
		{
			cachedVars.SetString(key, value);
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

	char url[MAX_URL_LENGTH];
	config.GetString("url", url, sizeof(url));

	char method[10];
	config.GetString("method", method, sizeof(method));

	ProxyServiceResponse response = ParseResponse(config);
	config.Rewind();
	config.JumpToKey(name);

	ProxyHTTPMethod httpMethod = GetHTTPMethodFromString(method);
	ProxyService service = new ProxyService(url, httpMethod, name, response);

	ParseAndSetParams(config, service, cachedVars);
	config.Rewind();
	config.JumpToKey(name);
	
	ParseAndSetHeaders(config, service, cachedVars);
	config.Rewind();
	config.JumpToKey(name);

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

			char tokenName[MAX_PARAM_VALUE_LENGTH];
			if (GetTokenFromInput(paramValue, tokenName, sizeof(tokenName)))
			{
				if (!vars.GetString(tokenName, paramValue, sizeof(paramValue)))
				{
					g_Logger.InfoMessage("Token \"%s\" does not exist in the root node!", tokenName);
				}
			}

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

			char tokenName[MAX_HEADER_VALUE_LENGTH];
			if (GetTokenFromInput(headerValue, tokenName, sizeof(tokenName)))
			{
				if (!vars.GetString(tokenName, headerValue, sizeof(headerValue)))
				{
					g_Logger.InfoMessage("Token \"%s\" does not exist in the root node!", tokenName);
				}
			}

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