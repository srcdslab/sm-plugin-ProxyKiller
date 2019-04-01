// =========================================================== //

void QueryService(ProxyUser pUser, ProxyService service)
{
	// NOTE TO SELF: ProxyUser::IPAddress can be "Unknown"
	// In which case we do not want to continue
	char ipAddress[24];
	pUser.GetIPAddress(ipAddress, sizeof(ipAddress));
	
	char url[MAX_URL_LENGTH];
	service.GetUrl(url, sizeof(url));
	TokenizeAll(pUser, url, sizeof(url));
	
	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, url);

	if (request == null)
	{
		delete pUser;
		delete request;
		return;
	}
		
	HandleParameters(request, pUser, service.Params);
	HandleHeaders(request, pUser, service.Headers);

	ProxyContext ctx = new ProxyContext();
	ctx.User = pUser;
	ctx.Service = service;

	SteamWorks_SetHTTPCallbacks(request, OnRequest_Completed, _, OnRequest_DataReceived);
	SteamWorks_SetHTTPRequestContextValue(request, ctx);
	SteamWorks_SendHTTPRequest(request);
}

// =========================================================== //

public int OnRequest_Completed(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, ProxyContext ctx)
{
	if (failure || !requestSuccessful)
	{
		char steamId2[32];
		ctx.User.GetSteamId2(steamId2, sizeof(steamId2));
		
		char ipAddress[24];
		ctx.User.GetIPAddress(ipAddress, sizeof(ipAddress));
		
		char serviceName[MAX_SERVICE_NAME_LENGTH];
		ctx.Service.GetName(serviceName, sizeof(serviceName));
		
		g_Logger.LogLine("HTTP failure %d! - IP: %s - SteamId: %s - Service: %s", statusCode, ipAddress, steamId2, serviceName);
		
		delete ctx.User;
		delete ctx;
	}
}

public int OnRequest_DataReceived(Handle request, bool failure, int offset, int bytesReceived, ProxyContext ctx)
{
	if (!failure && request != null)
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnRequest_Data, ctx);
	}
	else
	{
		delete ctx.User;
		delete ctx;
	}

	delete request;
}

public int OnRequest_Data(const char[] response, ProxyContext ctx)
{
	bool result = HandleResponse(response, ctx);
	g_Cache.TryCache(ctx.User, ctx.Service, result);
	
	if (result)
	{
		KickClientSafe(ctx.User.Client);
	}

	delete ctx.User;
	delete ctx;
}

// =========================================================== //