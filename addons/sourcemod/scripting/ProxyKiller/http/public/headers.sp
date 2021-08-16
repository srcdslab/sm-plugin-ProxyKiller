// =========================================================== //

#define MAX_HEADER_NAME_LENGTH 64
#define MAX_HEADER_VALUE_LENGTH 256

// =========================================================== //

void SetHeaders(Handle request, ProxyHTTPHeaders headers)
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

			if (SteamWorks_SetHTTPRequestHeaderValue(request, headerName, headerValue))
			{
				g_Logger.DebugMessage("Header: \"%s\" = \"%s\"", headerName, headerValue);
			}
		}

		delete headerMap;
	}
}

// =========================================================== //