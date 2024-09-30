// =========================================================== //

public void SQLite_OnRules(Database db, DBResultSet results, const char[] error, ProxyUser pUser)
{
	g_Logger.PrintFrame();

	if (Rules_DB_Conn_Lost(results) || strlen(error) > 0 || results == null || !results.HasResults)
	{
		g_Logger.ErrorMessage("<Rules-SQLite> Uh oh! Encountered a SQL error! - \"%s\"", error);
		delete pUser;
		return;
	}

	if (results.RowCount <= 0)
	{
		TryGetCache(pUser);
	}
	else
	{
		if (results.FetchRow())
		{
			int timestamp = results.FetchInt(1);

			char expression[32];
			results.FetchString(0, expression, sizeof(expression));

			char dateTime[64];
			FormatTime(dateTime, sizeof(dateTime), NULL_STRING, timestamp);

			g_Logger.DebugMessage("Valid whitelist rule for \"%s\" (%s)", expression, dateTime);
		}

		delete pUser;
	}
}

public void SQLite_OnRuleGeneric(Database db, DBResultSet results, const char[] error, any data)
{
	g_Logger.PrintFrame();

	if (Rules_DB_Conn_Lost(results) || strlen(error) > 0)
	{
		g_Logger.ErrorMessage("<Rules-SQLite> Uh oh! Encountered a SQL error! - \"%s\"", error);
		return;
	}
}

// =========================================================== //
