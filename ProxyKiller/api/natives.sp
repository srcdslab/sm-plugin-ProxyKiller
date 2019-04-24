// =========================================================== //

void CreateNatives()
{
	CreateNative("ProxyKiller_CreateHTTP", Native_CreateHTTP);
	CreateNative("ProxyKiller_CheckClient", Native_CheckClient);
	CreateNative("ProxyKiller_SendRequest", Native_SendRequest);
}

// =========================================================== //

public int Native_CheckClient(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int userid = GetClientUserId(client);

	ProxyUser pUser = new ProxyUser(userid);
	pUser.GetAndSetSteamId2();
	pUser.GetAndSetIPAddress();
	DetermineAndDoCachingStrategy(pUser);
}

public int Native_SendRequest(Handle plugin, int numParams)
{
	ProxyHTTP http = GetNativeCell(1);
	Function callback = GetNativeCell(2);
	any data = GetNativeCell(3);

	Handle fwd = CreateForward(ET_Ignore, Param_Cell, Param_String, Param_Cell);
	AddToForward(fwd, plugin, callback);
	
	http.Callback = fwd;
	QueryHTTP(http, data);
}

public int Native_CreateHTTP(Handle plugin, int numParams)
{
	char url[256];
	GetNativeString(1, url, sizeof(url));
	
	ProxyHTTPMethod method = GetNativeCell(2);
	bool isPersistent = GetNativeCell(3);
	
	ProxyHTTP http = new ProxyHTTP(isPersistent);
	http.Method = method;
	http.SetUrl(url);
	
	return view_as<int>(http);
}

// =========================================================== //