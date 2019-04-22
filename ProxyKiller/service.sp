// =========================================================== //

void QueryService(ProxyUser pUser, ProxyService service)
{
	InfoMessage("HTTP::QueryService");
	
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
	InfoMessage("HTTP::OnService");
	
	bool result = HandleResponse(responseData, ctx);
	Call_ProxyKiller_OnClientResult(ctx.User, result, false);
	
	bool blockCacheExec = Call_ProxyKiller_DoClientResultCache(ctx.User, result) != Plugin_Continue;
	
	if (!blockCacheExec)
	{
		g_Cache.TryCache(ctx.User, ctx.Service, result);
		Call_ProxyKiller_OnClientResultCache(ctx.User, result);
	}

	if (result)
	{
		bool blockPunishmentExec = Call_ProxyKiller_DoClientPunishment(ctx.User, false) != Plugin_Continue;
		
		if (!blockPunishmentExec)
		{
			KickClientSafe(ctx.User.Client);
			Call_ProxyKiller_OnClientPunishment(ctx.User, false);
		}
	}

	if (ctx != null)
	{
		ctx.Cleanup();
	}
}

// =========================================================== //