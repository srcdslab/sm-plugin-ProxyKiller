// =========================================================== //

public void MySQL_OnCache(Database db, DBResultSet results, const char[] error, ProxyUser pUser)
{
	g_Logger.PrintFrame();

	if (strlen(error) > 0 || !results.HasResults)
	{
		g_Logger.ErrorMessage("<Cache-MySQL> Uh oh! Encountered a SQL error! - \"%s\"", error);
		return;
	}

	if (results.RowCount <= 0)
	{
		QueryService(pUser, g_Config.Service);
	}
	else
	{
		if (results.FetchRow())
		{
			bool result = !!results.FetchInt(2);
			int timestamp = results.FetchInt(3);
			
			char ipAddress[24];
			results.FetchString(0, ipAddress, sizeof(ipAddress));
			
			char serviceName[MAX_SERVICE_NAME_LENGTH];
			results.FetchString(1, serviceName, sizeof(serviceName));

			if ((GetTime() - timestamp) >= gCV_CacheLifetime.IntValue)
			{
				QueryService(pUser, g_Config.Service);
			}
			else
			{
				if (result)
				{
					DoPunishment(pUser);
				}
				delete pUser;
			}
		}
	}
}

public void MySQL_OnCached(Database db, DBResultSet results, const char[] error, any data)
{
	g_Logger.PrintFrame();
	
	if (strlen(error) > 0)
	{
		g_Logger.ErrorMessage("<Cache-MySQL> Uh oh! Encountered a SQL error! - \"%s\"", error);
		return;
	}
}

// =========================================================== //
