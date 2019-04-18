// =========================================================== //

#define MAX_HEADER_NAME_LENGTH 64
#define MAX_HEADER_VALUE_LENGTH 256

// =========================================================== //

void HandleHeaders(Handle request, ProxyHTTPHeaders headers, ProxyUser pUser = null)
{
	if (headers != null)
	{
		StringMapSnapshot headerMap = headers.Snapshot();

		for (int i = 0; i < headerMap.Length; i++)
		{
			char headerName[MAX_HEADER_NAME_LENGTH];
			headerMap.GetKey(i, headerName, sizeof(headerName));
			
			if (!json_is_meta_key(headerName))
			{
				char headerValue[MAX_HEADER_VALUE_LENGTH];
				headers.GetString(headerName, headerValue, sizeof(headerValue));
				
				if (pUser != null)
				{
					TokenizeAll(pUser, headerName, sizeof(headerName));
					TokenizeAll(pUser, headerValue, sizeof(headerValue));
				}

				SteamWorks_SetHTTPRequestHeaderValue(request, headerName, headerValue);
			}
		}

		delete headerMap;
	}
}

// =========================================================== //