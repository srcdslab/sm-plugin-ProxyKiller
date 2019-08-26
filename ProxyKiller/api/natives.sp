// =========================================================== //

void CreateNatives()
{
	CreateNative("ProxyKiller_CreateHTTP", Native_CreateHTTP);
	CreateNative("ProxyKiller_CheckClient", Native_CheckClient);
	CreateNative("ProxyKiller_SendHTTPRequest", Native_SendHTTPRequest);

	CreateNative("ProxyKiller_GetCache", Native_GetCache);
	CreateNative("ProxyKiller_GetRules", Native_GetRules);
	CreateNative("ProxyKiller_GetConfig", Native_GetConfig);
	CreateNative("ProxyKiller_GetLogger", Native_GetLogger);
	CreateNative("ProxyKiller_IsCacheInit", Native_IsCacheInit);
	CreateNative("ProxyKiller_IsRulesInit", Native_IsRulesInit);
	CreateNative("ProxyKiller_IsConfigInit", Native_IsConfigInit);
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

public int Native_GetCache(Handle plugin, int numParams)
{
	return view_as<int>(CloneHandle(g_Cache, plugin));
}

public int Native_GetRules(Handle plugin, int numParams)
{
	return view_as<int>(CloneHandle(g_Rules, plugin));
}

public int Native_GetConfig(Handle plugin, int numParams)
{
	return view_as<int>(CloneHandle(g_Config, plugin));
}

public int Native_GetLogger(Handle plugin, int numParams)
{
	return view_as<int>(CloneHandle(g_Logger, plugin));
}

public int Native_IsCacheInit(Handle plugin, int numParams)
{
	return IsCacheInit();
}

public int Native_IsRulesInit(Handle plugin, int numParams)
{
	return IsRulesInit();
}

public int Native_IsConfigInit(Handle plugin, int numParams)
{
	return IsConfigInit();
}

// =========================================================== //