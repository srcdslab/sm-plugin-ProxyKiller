// =========================================================== //

void AddTokenizedParams(ProxyHTTP http, ProxyHTTPParams params, ProxyUser pUser)
{
	g_Logger.PrintFrame();

	if (params != null)
	{
		StringMapSnapshot paramMap = params.Snapshot();

		for (int i = 0; i < paramMap.Length; i++)
		{
			char paramName[MAX_PARAM_NAME_LENGTH];
			paramMap.GetKey(i, paramName, sizeof(paramName));

			char paramValue[MAX_PARAM_VALUE_LENGTH];
			params.GetString(paramName, paramValue, sizeof(paramValue));

			ExpandRuntimeVariables(pUser, paramName, sizeof(paramName));
			ExpandRuntimeVariables(pUser, paramValue, sizeof(paramValue));

			http.Params.AddParam(paramName, paramValue);
		}

		delete paramMap;
	}
}

void AddTokenizedHeaders(ProxyHTTP http, ProxyHTTPHeaders headers, ProxyUser pUser)
{
	g_Logger.PrintFrame();

	if (headers != null)
	{
		StringMapSnapshot headerMap = headers.Snapshot();

		for (int i = 0; i < headerMap.Length; i++)
		{
			char headerName[MAX_HEADER_NAME_LENGTH];
			headerMap.GetKey(i, headerName, sizeof(headerName));

			char headerValue[MAX_HEADER_VALUE_LENGTH];
			headers.GetString(headerName, headerValue, sizeof(headerValue));

			ExpandRuntimeVariables(pUser, headerName, sizeof(headerName));
			ExpandRuntimeVariables(pUser, headerValue, sizeof(headerValue));

			http.Headers.AddHeader(headerName, headerValue);
		}

		delete headerMap;
	}
}

// =========================================================== //