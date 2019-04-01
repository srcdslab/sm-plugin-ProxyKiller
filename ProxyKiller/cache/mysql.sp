// =========================================================== //

public void MySQL_OnCache(Database db, DBResultSet results, const char[] error, ProxyUser pUser)
{
	PrintToServer("MYSQL: Cache hit");

	if (strlen(error) > 0 || !results.HasResults)
	{
		LogError("<Cache-MySQL> Uh oh! Encountered a SQL error! - \"%s\"", error);
		return;
	}

	if (results.RowCount <= 0)
	{
		QueryService(pUser, g_Service);
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
			
			PrintToServer("> IP: %s", ipAddress);
			PrintToServer("> Service: %s", serviceName);
			PrintToServer("> Result: %d", result);
			PrintToServer("> Timestamp: %d\n", timestamp);

			if ((GetTime() - timestamp) >= gCV_CacheLifetime.IntValue)
			{
				QueryService(pUser, g_Service);
			}
			else
			{
				if (result)
				{
					KickClientSafe(pUser.Client);
				}
				
				delete pUser;
			}
		}
	}
}

public void MySQL_OnCached(Database db, DBResultSet results, const char[] error, any data)
{
	PrintToServer("MYSQL: Cached");
	
	if (strlen(error) > 0)
	{
		LogError("<Cache-MySQL> Uh oh! Encountered a SQL error! - \"%s\"", error);
		return;
	}
}

// =========================================================== //
