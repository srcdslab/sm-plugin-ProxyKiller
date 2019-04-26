// =========================================================== //

// TODO: Make this return a boolean
void QueryHTTP(ProxyHTTP http, any data)
{
	InfoMessage("HTTP::QueryHTTP");
	
	char url[MAX_URL_LENGTH];
	http.GetUrl(url, sizeof(url));
	
	EHTTPMethod method = GetSteamWorksMethod(http.Method);
	Handle request = SteamWorks_CreateHTTPRequest(method, url);
	
	if (request == null)
	{
		if (http != null)
		{
			http.Cleanup();
		}

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
	
	int status = view_as<int>(statusCode);
	bool fail = failure || !requestSuccessful;

	ctx.HTTP.Response = new ProxyHTTPResponse(fail, status);
	
	if (fail)
	{
		// Error logging
	}
}

// =========================================================== //

public int OnRequest_DataReceived(Handle request, bool failure, int offset, int bytesReceived, ProxyHTTPContext ctx)
{
	InfoMessage("HTTP::OnRequestDataReceived");

	// TODO: Fire forward even when failure AND response body is 0
	if (!failure)
	{
		SteamWorks_GetHTTPResponseBodyCallback(request, OnRequest_Data, ctx);
	}

	if (ctx != null)
	{
		ctx.Cleanup();
	}

	delete request;
}

// =========================================================== //

public int OnRequest_Data(const char[] responseData, ProxyHTTPContext ctx)
{
	InfoMessage("HTTP::OnRequestData");
	DoCallback(ctx.HTTP.Callback, ctx.HTTP.Response, responseData, ctx.Data);
}

// =========================================================== //