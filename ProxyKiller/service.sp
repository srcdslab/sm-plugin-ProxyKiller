// =========================================================== //

void QueryService(ProxyUser pUser, ProxyService service)
{
	g_Logger.DebugMessage("HTTP::QueryService");
	
	char url[MAX_URL_LENGTH];
	service.GetUrl(url, sizeof(url));
	TokenizeAll(pUser, url, sizeof(url));
	
	service.SetUrl(url);

	ProxyServiceContext ctx = new ProxyServiceContext();
	ctx.User = pUser;
	ctx.Service = service;

	ProxyKiller_SendRequest(service, OnService, ctx);
}

// =========================================================== //

public void OnService(ProxyHTTPResponse response, const char[] responseData, ProxyServiceContext ctx)
{
	g_Logger.DebugMessage("HTTP::OnService");
	
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