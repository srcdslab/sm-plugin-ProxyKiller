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
}

// =========================================================== //

public int Native_CheckClient(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int userid = GetClientUserId(client);

	ProxyUser pUser = new ProxyUser(userid);
	pUser.GetAndSetSteamId2();
	pUser.GetAndSetIPAddress();
	TryGetRules(pUser);
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

// =========================================================== //