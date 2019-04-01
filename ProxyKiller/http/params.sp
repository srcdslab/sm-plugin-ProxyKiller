// =========================================================== //

#define MAX_PARAM_NAME_LENGTH 64
#define MAX_PARAM_VALUE_LENGTH 128

// =========================================================== //

void HandleParameters(Handle request, ProxyUser pUser, ProxyServiceParams params)
{
	if (params != null)
	{
		StringMapSnapshot paramMap = params.Snapshot();

		for (int i = 0; i < paramMap.Length; i++)
		{
			char paramName[MAX_PARAM_NAME_LENGTH];
			paramMap.GetKey(i, paramName, sizeof(paramName));
			
			if (!json_is_meta_key(paramName))
			{
				char paramValue[MAX_PARAM_VALUE_LENGTH];
				params.GetString(paramName, paramValue, sizeof(paramValue));
				
				TokenizeAll(pUser, paramName, sizeof(paramName));
				TokenizeAll(pUser, paramValue, sizeof(paramValue));
				SteamWorks_SetHTTPRequestGetOrPostParameter(request, paramName, paramValue);
			}
		}

		delete paramMap;
	}
}

// =========================================================== //