// =========================================================== //

void CreateNatives()
{
	CreateNative("ProxyKiller_CheckClient", Native_CheckClient);
	CreateNative("ProxyKiller_CreateHTTP", Native_CreateHTTP);
	CreateNative("ProxyKiller_SendHTTPRequest", Native_SendHTTPRequest);

	CreateNative("ProxyKiller_GetRawVersion", Native_GetRawVersion);
	CreateNative("ProxyKiller_GetSemVersion", Native_GetSemVersion);
	CreateNative("ProxyKiller_GetMajorVersion", Native_GetMajorVersion);
	CreateNative("ProxyKiller_GetMinorVersion", Native_GetMinorVersion);
	CreateNative("ProxyKiller_GetPatchVersion", Native_GetPatchVersion);

	CreateNative("ProxyKiller_Cache_IsInit", Native_Cache_IsInit);
	CreateNative("ProxyKiller_Rules_IsInit", Native_Rules_IsInit);

	CreateNative("ProxyKiller_Logger_GetSpewMode", Native_Logger_GetSpewMode);
	CreateNative("ProxyKiller_Logger_GetSpewLevel", Native_Logger_GetSpewLevel);
	CreateNative("ProxyKiller_Logger_InfoMessage", Native_Logger_InfoMessage);
	CreateNative("ProxyKiller_Logger_ErrorMessage", Native_Logger_ErrorMessage);
	CreateNative("ProxyKiller_Logger_DebugMessage", Native_Logger_DebugMessage);

	CreateNative("ProxyKiller_Config_IsInit", Native_Config_IsInit);
	CreateNative("ProxyKiller_Config_HasVariable", Native_Config_HasVariable);
	CreateNative("ProxyKiller_Config_GetVariable", Native_Config_GetVariable);
	CreateNative("ProxyKiller_Config_GetServiceName", Native_Config_GetServiceName);
	CreateNative("ProxyKiller_Config_GetServiceResponseValue", Native_Config_GetServiceResponseValue);
	CreateNative("ProxyKiller_Config_GetServiceResponseObject", Native_Config_GetServiceResponseObject);
	CreateNative("ProxyKiller_Config_GetServiceResponseType", Native_Config_GetServiceResponseType);
	CreateNative("ProxyKiller_Config_GetServiceResponseCompare", Native_Config_GetServiceResponseCompare);
}

// =========================================================== //

public int Native_CheckClient(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (client <= 0 || client > MaxClients)
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index passed!");
		return false;
	}

	if (!IsClientConnected(client))
	{
		ThrowNativeError(SP_ERROR_NATIVE, "Client passed in was not connected!");
		return false;
	}

	TryGetRules(new ProxyUser(client));
	return 1;
}

public int Native_CreateHTTP(Handle plugin, int numParams)
{
	char url[256];
	GetNativeString(1, url, sizeof(url));

	ProxyHTTPMethod method = GetNativeCell(2);
	bool isPersistent = GetNativeCell(3);

	return view_as<int>(new ProxyHTTP(url, method, isPersistent));
}

public int Native_SendHTTPRequest(Handle plugin, int numParams)
{
	ProxyHTTP http = GetNativeCell(1);
	Function callback = GetNativeCell(2);
	any data = GetNativeCell(3);

	Handle fwd = CreateForward(ET_Ignore, Param_Cell, Param_String, Param_Cell);
	AddToForward(fwd, plugin, callback);

	http.Callback = fwd;
	return QueryHTTP(http, data);
}

public int Native_GetRawVersion(Handle plugin, int numParams)
{
	char ver[64];
	if (!GetPluginInfo(null, PlInfo_Version, ver, sizeof(ver)))
	{
		return false;
	}

	int maxlength = GetNativeCell(2);
	return SetNativeString(1, ver, maxlength) == SP_ERROR_NONE;
}

public int Native_GetSemVersion(Handle plugin, int numParams)
{
	char ver[64];
	GetNativeString(1, ver, sizeof(ver));

	if (IsNativeParamNullString(1))
	{
		ProxyKiller_GetRawVersion(ver, sizeof(ver));
	}

	bool validSemVer = false;
	Regex regex = new Regex("^(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)");

	if (regex.Match(ver) >= 1)
	{
		validSemVer = true;
		regex.GetSubString(0, ver, sizeof(ver));
	}

	if (validSemVer)
	{
		int maxlength = GetNativeCell(3);
		SetNativeString(2, ver, maxlength);
	}

	delete regex;
	return validSemVer;
}

public int Native_GetMajorVersion(Handle plugin, int numParams)
{
	char ver[64];
	GetNativeString(1, ver, sizeof(ver));

	if (IsNativeParamNullString(1))
	{
		ProxyKiller_GetRawVersion(ver, sizeof(ver));
	}

	if (!ProxyKiller_GetSemVersion(ver, ver, sizeof(ver)))
	{
		return -1;
	}

	char vers[3][22];
	ExplodeString(ver, ".", vers, sizeof(vers), sizeof(vers[]));

	return StringToInt(vers[0]);
}

public int Native_GetMinorVersion(Handle plugin, int numParams)
{
	char ver[64];
	GetNativeString(1, ver, sizeof(ver));

	if (IsNativeParamNullString(1))
	{
		ProxyKiller_GetRawVersion(ver, sizeof(ver));
	}

	if (!ProxyKiller_GetSemVersion(ver, ver, sizeof(ver)))
	{
		return -1;
	}

	char vers[3][22];
	ExplodeString(ver, ".", vers, sizeof(vers), sizeof(vers[]));

	return StringToInt(vers[1]);
}

public int Native_GetPatchVersion(Handle plugin, int numParams)
{
	char ver[64];
	GetNativeString(1, ver, sizeof(ver));

	if (IsNativeParamNullString(1))
	{
		ProxyKiller_GetRawVersion(ver, sizeof(ver));
	}

	if (!ProxyKiller_GetSemVersion(ver, ver, sizeof(ver)))
	{
		return -1;
	}

	char vers[3][22];
	ExplodeString(ver, ".", vers, sizeof(vers), sizeof(vers[]));

	return StringToInt(vers[2]);
}

public int Native_Cache_IsInit(Handle plugin, int numParams)
{
	return IsCacheInit();
}

public int Native_Rules_IsInit(Handle plugin, int numParams)
{
	return IsRulesInit();
}

public int Native_Config_IsInit(Handle plugin, int numParams)
{
	return IsConfigInit();
}

public int Native_Logger_GetSpewMode(Handle plugin, int numParams)
{
	return g_Logger.SpewMode;
}

public int Native_Logger_GetSpewLevel(Handle plugin, int numParams)
{
	return g_Logger.SpewLevel;
}

public int Native_Logger_InfoMessage(Handle plugin, int numParams)
{
	char buffer[400];
	FormatNativeString(0, 1, 2, sizeof(buffer), _, buffer);

	char plFile[64];
	GetPluginFilename(plugin, plFile, sizeof(plFile));
	return g_Logger.InfoMessage("[%s] \"%s\"", plFile, buffer);
}

public int Native_Logger_ErrorMessage(Handle plugin, int numParams)
{
	char buffer[400];
	FormatNativeString(0, 1, 2, sizeof(buffer), _, buffer);

	char plFile[64];
	GetPluginFilename(plugin, plFile, sizeof(plFile));
	return g_Logger.ErrorMessage("[%s] \"%s\"", plFile, buffer);
}

public int Native_Logger_DebugMessage(Handle plugin, int numParams)
{
	char buffer[400];
	FormatNativeString(0, 1, 2, sizeof(buffer), _, buffer);

	char plFile[64];
	GetPluginFilename(plugin, plFile, sizeof(plFile));
	return g_Logger.DebugMessage("[%s] \"%s\"", plFile, buffer);
}

public int Native_Config_HasVariable(Handle plugin, int numParams)
{
	char variable[MAX_CONFIG_VARIABLE_NAME];
	GetNativeString(1, variable, sizeof(variable));

	char dummy[1];
	return g_Config.Vars.GetString(variable, dummy, sizeof(dummy));
}

public int Native_Config_GetVariable(Handle plugin, int numParams)
{
	char variable[MAX_CONFIG_VARIABLE_NAME];
	GetNativeString(1, variable, sizeof(variable));

	char varValue[MAX_CONFIG_VARIABLE_VALUE];
	bool result = g_Config.Vars.GetString(variable, varValue, sizeof(varValue));

	if (result)
	{
		int maxlength = GetNativeCell(3);
		SetNativeString(2, varValue, maxlength);
	}

	return result;
}

public int Native_Config_GetServiceName(Handle plugin, int numParams)
{
	char serviceName[MAX_SERVICE_NAME_LENGTH];
	g_Config.Service.GetName(serviceName, sizeof(serviceName));

	int maxlength = GetNativeCell(2);
	return SetNativeString(1, serviceName, maxlength) == SP_ERROR_NONE;
}

public int Native_Config_GetServiceResponseValue(Handle plugin, int numParams)
{
	char value[MAX_RESPONSE_NAME_LENGTH];
	g_Config.Service.ExpectedResponse.GetValue(value, sizeof(value));

	int maxlength = GetNativeCell(2);
	return SetNativeString(1, value, maxlength) == SP_ERROR_NONE;
}

public int Native_Config_GetServiceResponseObject(Handle plugin, int numParams)
{
	if (g_Config.Service.ExpectedResponse.Type != ResponseType_JSON)
	{
		return false;
	}

	char objStr[MAX_RESPONSE_OBJECT_LENGTH];
	g_Config.Service.ExpectedResponse.GetObject(objStr, sizeof(objStr));

	int maxlength = GetNativeCell(2);
	return SetNativeString(1, objStr, maxlength) == SP_ERROR_NONE;
}

public int Native_Config_GetServiceResponseType(Handle plugin, int numParams)
{
	return view_as<int>(g_Config.Service.ExpectedResponse.Type);
}

public int Native_Config_GetServiceResponseCompare(Handle plugin, int numParams)
{
	return view_as<int>(g_Config.Service.ExpectedResponse.Compare);
}

// =========================================================== //