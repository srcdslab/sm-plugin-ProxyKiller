// =========================================================== //

bool QueryService(ProxyUser pUser, ProxyService service)
{
	g_Logger.PrintFrame();

	char url[MAX_HTTP_URL_LENGTH];
	service.GetUrl(url, sizeof(url));
	ExpandRuntimeVariables(pUser, url, sizeof(url));

	ProxyHTTP http = ProxyKiller_CreateHTTP(url, service.Method, false);

	AddTokenizedParams(http, service.Params, pUser);
	AddTokenizedHeaders(http, service.Headers, pUser);

	ProxyServiceContext ctx = new ProxyServiceContext();
	ctx.User = pUser;
	ctx.Service = service;

	return ProxyKiller_SendHTTPRequest(http, OnService, ctx);
}

// =========================================================== //

public void OnService(ProxyHTTPResponse response, const char[] responseStr, ProxyServiceContext ctx)
{
	g_Logger.PrintFrame();

	if (response.Failure)
	{
		char service[MAX_SERVICE_NAME_LENGTH];
		ctx.Service.GetName(service, sizeof(service));

		g_Logger.ErrorMessage("Error occured while querying service %s", service);
		return;
	}

	bool result = GetResultFromResponse(responseStr, ctx);
	Call_OnClientResult(ctx.User, result, false);

	if (Call_DoClientResultCache(ctx.User, result))
	{
		TryPushCache(ctx.User, ctx.Service, result);
	}

	if (result)
	{
		if (Call_DoClientPunishment(ctx.User, false))
		{
			DoPunishment(ctx.User, false);
		}
	}

	if (ctx != null)
	{
		ctx.Dispose();
	}
}

// =========================================================== //