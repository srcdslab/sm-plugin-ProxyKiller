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

public void OnService(bool failure, char[] response, ProxyServiceContext ctx)
{
	InfoMessage("HTTP::OnService");
	
	bool result = HandleResponse(response, ctx);
	g_Cache.TryCache(ctx.User, ctx.Service, result);
	
	if (result)
	{
		KickClientSafe(ctx.User.Client);
	}

	delete ctx.User;
	delete ctx.Service;
	delete ctx;
}

// =========================================================== //