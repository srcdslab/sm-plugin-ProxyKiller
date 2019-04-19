// =========================================================== //

void QueryHTTP(ProxyHTTP http, any data)
{
	InfoMessage("HTTP::QueryHTTP");
	
	char url[MAX_URL_LENGTH];
	http.GetUrl(url, sizeof(url));

	Handle request = SteamWorks_CreateHTTPRequest(http.Method, url);
	
	if (request == null)
	{
		// TODO: ProxyHTTP has headers & params which also need to be deleted
		delete http;
		delete request;
		return;
	}
	
	HandleParameters(request, http.Params);
	HandleHeaders(request, http.Headers);

	ProxyHTTPContext ctx = new ProxyHTTPContext();
	ctx.HTTP = http;
	ctx.Data = data;

	SteamWorks_SetHTTPCallbacks(request, OnRequest_Completed, _, OnRequest_DataReceived);
	SteamWorks_SetHTTPRequestContextValue(request, ctx);
	SteamWorks_SendHTTPRequest(request);
}

// =========================================================== //

public int OnRequest_Completed(Handle request, bool failure, bool requestSuccessful, EHTTPStatusCode statusCode, ProxyHTTPContext ctx)
{
	InfoMessage("HTTP::OnRequestCompleted");
	
	if (failure || !requestSuccessful)
	{
		// Error logging
	}
}

// =========================================================== //

public int OnRequest_DataReceived(Handle request, bool failure, int offset, int bytesReceived, ProxyHTTPContext ctx)
{
	InfoMessage("HTTP::OnRequestDataReceived");

	if (!failure)
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnRequest_Data, ctx);
	}

	if (ctx != null)
	{
		ctx.Cleanup();
		delete ctx;
	}

	delete request;
}

// =========================================================== //

public int OnRequest_Data(const char[] response, ProxyHTTPContext ctx)
{
	InfoMessage("HTTP::OnRequestData");
	DoCallback(ctx.HTTP.Callback, false, response, ctx.Data);
}

// =========================================================== //