// =========================================================== //

#define MAX_PARAM_NAME_LENGTH 64
#define MAX_PARAM_VALUE_LENGTH 256

// =========================================================== //

void SetParams(Handle request, ProxyHTTPParams params)
{
	g_Logger.PrintFrame();

	if (params != null)
	{
		if (params.StringKeyExists("__rawbody"))
		{
			char body[4096];
			params.GetString("__rawbody", body, sizeof(body));
			
			char bodyType[MAX_PARAM_VALUE_LENGTH];
			params.GetString("__rawbody_type", bodyType, sizeof(bodyType));

			// Only early return if the body was actually successfully set
			// This will FAIL on GET requests at least, allowing the params still to be added
			if (SteamWorks_SetHTTPRequestRawPostBody(request, bodyType, body, strlen(body)))
			{
				g_Logger.DebugMessage("Request body \"%s\" = \"%s\"", bodyType, body);
				return;
			}
		}

		StringMapSnapshot paramMap = params.Snapshot();
		for (int i = 0; i < paramMap.Length; i++)
		{
			char paramName[MAX_PARAM_NAME_LENGTH];
			paramMap.GetKey(i, paramName, sizeof(paramName));
	
			char paramValue[MAX_PARAM_VALUE_LENGTH];
			params.GetString(paramName, paramValue, sizeof(paramValue));

			if (SteamWorks_SetHTTPRequestGetOrPostParameter(request, paramName, paramValue))
			{
				g_Logger.DebugMessage("Param: \"%s\" = \"%s\"", paramName, paramValue);
			}
		}

		delete paramMap;
	}
}

// =========================================================== //