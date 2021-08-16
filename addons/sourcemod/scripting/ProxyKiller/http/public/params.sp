// =========================================================== //

#define MAX_PARAM_NAME_LENGTH 64
#define MAX_PARAM_VALUE_LENGTH 256

// =========================================================== //

void SetParams(Handle request, ProxyHTTPParams params)
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

			if (SteamWorks_SetHTTPRequestGetOrPostParameter(request, paramName, paramValue))
			{
				g_Logger.DebugMessage("Param: \"%s\" = \"%s\"", paramName, paramValue);
			}
		}

		delete paramMap;
	}
}

// =========================================================== //