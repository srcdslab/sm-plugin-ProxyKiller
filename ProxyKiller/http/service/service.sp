// =========================================================== //

void QueryService(ProxyUser pUser, ProxyService service)
{
	g_Logger.PrintFrame();
	
	char url[MAX_URL_LENGTH];
	service.GetUrl(url, sizeof(url));
	TokenizeAll(pUser, url, sizeof(url));

	ProxyHTTP http = ProxyKiller_CreateHTTP(url, service.Method, false);
	
	AddTokenizedParams(http, service.Params, pUser);
	AddTokenizedHeaders(http, service.Headers, pUser);

	ProxyServiceContext ctx = new ProxyServiceContext();
	ctx.User = pUser;
	ctx.Service = service;

	ProxyKiller_SendHTTPRequest(http, OnService, ctx);
}

// =========================================================== //

public void OnService(ProxyHTTPResponse response, const char[] responseData, ProxyServiceContext ctx)
{
	g_Logger.PrintFrame();
	
	bool result = HandleResponse(responseData, ctx);
	Call_OnClientResult(ctx.User, result, false);
	
	bool blockCacheExec = Call_DoClientResultCache(ctx.User, result) != Plugin_Continue;

	if (!blockCacheExec)
	{
		TryPushCache(ctx.User, ctx.Service, result);
	}

	if (result)
	{
		bool blockPunishmentExec = Call_DoClientPunishment(ctx.User, false) != Plugin_Continue;
		
		if (!blockPunishmentExec)
		{
			KickClientSafe(ctx.User.Client);
			Call_OnClientPunishment(ctx.User, false);
		}
	}

	if (ctx != null)
	{
		ctx.Cleanup();
	}
}

// =========================================================== //