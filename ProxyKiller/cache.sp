// =========================================================== //

// INSERT - UPDATE
public void OnEntry(Database db, DBResultSet results, const char[] error, any data)
{
	if (strlen(error) > 0)
	{
		LogError("Uh oh! Encountered a SQL error! - \"%s\"", error);
		return;
	}
}

// SELECT - ONLY
public void OnCache(Database db, DBResultSet results, const char[] error, DataPack data)
{
	data.Reset();

	char ipAddress[24];
	data.ReadString(ipAddress, sizeof(ipAddress));

	char steamId[32];
	data.ReadString(steamId, sizeof(steamId));
	delete data;

	if (!results.HasResults || strlen(error) > 0)
	{
		LogError("Uh oh! Encountered a SQL error! - \"%s\"", error);
		return;
	}

	if (results.RowCount <= 0)
	{
		QueryServices(ipAddress, steamId);
	}
	else
	{
		if (results.FetchRow())
		{
			int timestamp = results.FetchInt(1);
			bool shouldBlock = results.FetchInt(0) == 1;
			int cacheLifetime = gCV_CacheLifetime.IntValue;

			if ((GetTime() - timestamp) >= cacheLifetime)
			{
				QueryServices(ipAddress, steamId);
				// Should be debug only log
				//g_Logger.LogLine("Cache expired! - Key %s - Expired: %s", ipAddress, dateTime);
			}
			else
			{
				// Should be debug only log
				//g_Logger.LogLine("Cache hit! - Key %s - Expires: %s", ipAddress, dateTime);

				if (shouldBlock)
				{
					KickClientsByIp(ipAddress);
					g_Logger.LogLine("Kicked IP %s [%s] due to proxy! (Cache hit)", ipAddress, steamId);
				}
			}
		}
	}
}

// =========================================================== //