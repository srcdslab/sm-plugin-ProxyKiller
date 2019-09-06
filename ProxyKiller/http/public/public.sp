// =========================================================== //

bool QueryHTTP(ProxyHTTP http, any data)
{
	g_Logger.PrintFrame();

	char url[MAX_HTTP_URL_LENGTH];
	http.GetUrl(url, sizeof(url));

	EHTTPMethod method = GetSteamWorksMethod(http.Method);
	Handle request = SteamWorks_CreateHTTPRequest(method, url);

	if (request == null)
	{
		if (http != null)
		{
			http.Dispose();
		}

		delete request;
		return false;
	}

	SetHeaders(request, http.Headers);

	if (!SetRawBody(request, http))
	{
		SetParams(request, http.Params);
	}

	ProxyHTTPContext ctx = new ProxyHTTPContext();
	ctx.HTTP = http;
	ctx.Data = data;

	SteamWorks_SetHTTPCallbacks(request, OnRequest_Completed, _, OnRequest_DataReceived);
	SteamWorks_SetHTTPRequestUserAgentInfo(request, " ProxyKiller");
	SteamWorks_SetHTTPRequestContextValue(request, ctx);
	SteamWorks_SendHTTPRequest(request);
	return true;
}

// =========================================================== //

public int OnRequest_Completed(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, ProxyHTTPContext ctx)
{
	g_Logger.PrintFrame();

	int status = view_as<int>(statusCode);
	bool fail = failure || !requestSuccessful;

	ctx.HTTP.Response = new ProxyHTTPResponse(fail, status);

	if (fail)
	{
		char requestUrl[MAX_HTTP_URL_LENGTH];
		ctx.HTTP.GetUrl(requestUrl, sizeof(requestUrl));
		g_Logger.ErrorMessage("Error making http request to \"%s\" - Status: %d", requestUrl, status);
	}
}

// =========================================================== //

public int OnRequest_DataReceived(Handle request, bool failure, int offset, int bytesReceived, ProxyHTTPContext ctx)
{
	g_Logger.PrintFrame();

	if (!failure)
	{
		int bodySize = 0;
		SteamWorks_GetHTTPResponseBodySize(request, bodySize);

		if (bodySize <= 0)
		{
			DoCallback(ctx.HTTP.Callback, ctx.HTTP.Response, "", ctx.Data);
		}
		else
		{
			if (ctx.HTTP.HasResponseFile)
			{
				char responseFile[PLATFORM_MAX_PATH];
				ctx.HTTP.GetResponseFile(responseFile, sizeof(responseFile));
				SteamWorks_WriteHTTPResponseBodyToFile(request, responseFile);
			}

			SteamWorks_GetHTTPResponseBodyCallback(request, OnRequest_Data, ctx);
		}
	}
	else
	{
		DoCallback(ctx.HTTP.Callback, ctx.HTTP.Response, "", ctx.Data);
	}

	if (ctx != null)
	{
		ctx.Dispose();
	}

	delete request;
}

// =========================================================== //

public int OnRequest_Data(const char[] responseData, ProxyHTTPContext ctx)
{
	g_Logger.PrintFrame();
	DoCallback(ctx.HTTP.Callback, ctx.HTTP.Response, responseData, ctx.Data);
}

// =========================================================== //