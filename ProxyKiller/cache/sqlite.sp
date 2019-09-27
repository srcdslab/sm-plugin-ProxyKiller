// =========================================================== //

public void SQLite_OnCache(Database db, DBResultSet results, const char[] error, ProxyUser pUser)
{
	g_Logger.PrintFrame();

	if (strlen(error) > 0 || results == null || !results.HasResults)
	{
		g_Logger.ErrorMessage("<Cache-SQLite> Uh oh! Encountered a SQL error! - \"%s\"", error);
		delete pUser;
		return;
	}

	if (results.RowCount <= 0)
	{
		QueryService(pUser, g_Config.Service);
	}
	else
	{
		bool inFlight = false;
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
				inFlight = QueryService(pUser, g_Config.Service);
			}
			else
			{
				Call_OnClientResult(pUser, result, true);
				if (result)
				{
					DoPunishment(pUser, true);
				}

				char dateTime[24];
				FormatTime(dateTime, sizeof(dateTime), NULL_STRING, timestamp);
				g_Logger.DebugMessage("Cache hit for \"%s\" - Result: %d (%s)", ipAddress, result, dateTime);
			}
		}

		if (!inFlight)
		{
			delete pUser;
		}
	}
}

public void SQLite_OnCached(Database db, DBResultSet results, const char[] error, any data)
{
	g_Logger.PrintFrame();

	if (strlen(error) > 0)
	{
		g_Logger.ErrorMessage("<Cache-SQLite> Uh oh! Encountered a SQL error! - \"%s\"", error);
		return;
	}
}

public void SQLite_OnOldEntriesDeleted(Database db, DBResultSet results, const char[] error, any data)
{
	g_Logger.PrintFrame();

	if (strlen(error) > 0)
	{
		g_Logger.ErrorMessage("<Cache-SQLite> Uh oh! Encountered a SQL error! - \"%s\"", error);
		return;
	}

	int deletedRows = 0;
	if (results != null)
	{
		deletedRows = results.AffectedRows;
	}

	if (deletedRows > 0)
	{
		g_Logger.InfoMessage("<Cache-SQLite> Removed %d old cache entries from database", deletedRows);
	}
}

// =========================================================== //
