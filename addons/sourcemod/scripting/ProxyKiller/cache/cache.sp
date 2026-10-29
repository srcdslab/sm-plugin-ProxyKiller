// =========================================================== //

static bool CacheInit = false;

#define Cache_MySQL(%1) view_as<ProxyCacheMySQL>(%1)
#define Cache_SQLite(%1) view_as<ProxyCacheSQLite>(%1)

// =========================================================== //

bool IsCacheInit()
{
	return CacheInit;
}

ProxyCache CreateCache(int mode)
{
	int minMode = view_as<int>(CacheMode_None);
	int maxMode = view_as<int>(CacheMode_COUNT) - 1;

	if (mode < minMode) mode = minMode;
	else if (mode > maxMode) mode = maxMode;

	ProxyCache cache = null;
	ProxyCacheMode cm = view_as<ProxyCacheMode>(mode);

	switch (cm)
	{
		case CacheMode_None:
		{
			g_Logger.PrintFrame("None");
			cache = new ProxyCache(cm);
		}
		case CacheMode_MySQL:
		{
			ProxyCacheMySQL_DB_Connect();

			char prefix[64];
			gCV_DatabaseTablePrefix.GetString(prefix, sizeof(prefix));
			
			g_Logger.PrintFrame("MySQL");
			cache = new ProxyCacheMySQL(prefix);
		}
		case CacheMode_SQLite:
		{
			ProxyCacheSQLite_DB_Connect();

			char prefix[64];
			gCV_DatabaseTablePrefix.GetString(prefix, sizeof(prefix));

			g_Logger.PrintFrame("SQLite");
			cache = new ProxyCacheSQLite(prefix);
		}
	}

	CacheInit = true;
	return cache;
}

void TryGetCache(ProxyUser pUser)
{
	Call_OnCheckClient(pUser);
	QueryCache(pUser);
}

// Also called again by DB_DeferClientCheck while the cache database is not connected
void QueryCache(ProxyUser pUser)
{
	switch (g_Cache.Mode)
	{
		case CacheMode_None:
		{
			QueryService(pUser, g_Config.Service);
		}
		case CacheMode_MySQL:
		{
			if (!Cache_MySQL(g_Cache).TryGetCache(pUser, g_Config.Service, MySQL_OnCache))
			{
				DB_DeferClientCheck(pUser, false);
			}
		}
		case CacheMode_SQLite:
		{
			if (!Cache_SQLite(g_Cache).TryGetCache(pUser, g_Config.Service, SQLite_OnCache))
			{
				DB_DeferClientCheck(pUser, false);
			}
		}
		default:
		{
			g_Logger.DebugMessage("Cache mode %d has no implementation for TryGetCache", g_Cache.Mode);
		}
	}
}

void TryPushCache(ProxyUser pUser, ProxyService service, any result)
{
	Call_OnClientResultCache(pUser, result);

	switch (g_Cache.Mode)
	{
		case CacheMode_MySQL:
		{
			if (!Cache_MySQL(g_Cache).TryPushCache(pUser, service, result, MySQL_OnCached))
			{
				g_Logger.ErrorMessage("<Cache-MySQL> Database not connected, result not cached");
			}
		}
		case CacheMode_SQLite:
		{
			if (!Cache_SQLite(g_Cache).TryPushCache(pUser, service, result, SQLite_OnCached))
			{
				g_Logger.ErrorMessage("<Cache-SQLite> Database not connected, result not cached");
			}
		}
		default:
		{
			g_Logger.DebugMessage("Cache mode %d has no implementation for TryPushCache", g_Cache.Mode);
		}
	}
}

public bool Cache_DB_Conn_Lost(DBResultSet results, const char[] error)
{
	switch (g_Cache.Mode)
	{
		case CacheMode_MySQL:
		{
			return ProxyCacheMySQL_DB_Conn_Lost(results, error);
		}
		case CacheMode_SQLite:
		{
			return ProxyCacheSQLite_DB_Conn_Lost(results, error);
		}
		default:
		{
			g_Logger.DebugMessage("Cache mode %d has no implementation for DB_Conn_Lost", g_Cache.Mode);
		}
	}

	return false;
}

public Action Timer_DeleteOldCacheEntries(Handle timer)
{
	// The methods skip the query while the database is not connected
	switch (g_Cache.Mode)
	{
		case CacheMode_MySQL:
		{
			Cache_MySQL(g_Cache).TryDeleteOldEntries(gCV_CacheLifetime.IntValue, MySQL_OnOldEntriesDeleted);
		}
		case CacheMode_SQLite:
		{
			Cache_SQLite(g_Cache).TryDeleteOldEntries(gCV_CacheLifetime.IntValue, SQLite_OnOldEntriesDeleted);
		}
	}
	return Plugin_Continue;
}

// =========================================================== //