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
			Cache_MySQL(cache).Initialize();
		}
		case CacheMode_SQLite:
		{
			ProxyCacheSQLite_DB_Connect();

			char prefix[64];
			gCV_DatabaseTablePrefix.GetString(prefix, sizeof(prefix));
			
			g_Logger.PrintFrame("SQLite");
			cache = new ProxyCacheSQLite(prefix);
			Cache_SQLite(cache).Initialize();
		}
	}

	CacheInit = true;
	return cache;
}

void TryGetCache(ProxyUser pUser)
{
	Call_OnCheckClient(pUser);

	switch (g_Cache.Mode)
	{
		case CacheMode_None:
		{
			QueryService(pUser, g_Config.Service);
		}
		case CacheMode_MySQL:
		{
			Cache_MySQL(g_Cache).TryGetCache(pUser, g_Config.Service, MySQL_OnCache);
		}
		case CacheMode_SQLite:
		{
			Cache_SQLite(g_Cache).TryGetCache(pUser, g_Config.Service, SQLite_OnCache);
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
			Cache_MySQL(g_Cache).TryPushCache(pUser, service, result, MySQL_OnCached);
		}
		case CacheMode_SQLite:
		{
			Cache_SQLite(g_Cache).TryPushCache(pUser, service, result, SQLite_OnCached);
		}
		default:
		{
			g_Logger.DebugMessage("Cache mode %d has no implementation for TryPushCache", g_Cache.Mode);
		}
	}
}

public void Cache_DB_Conn_Lost(DBResultSet results)
{
	switch (g_Cache.Mode)
	{
		case CacheMode_MySQL:
		{
			ProxyCacheMySQL_DB_Conn_Lost(results);
		}
		case CacheMode_SQLite:
		{
			ProxyCacheSQLite_DB_Conn_Lost(results);
		}
		default:
		{
			g_Logger.DebugMessage("Cache mode %d has no implementation for DB_Conn_Lost", g_Cache.Mode);
		}
	}
}

public Action Timer_DeleteOldCacheEntries(Handle timer)
{
	if (g_Cache.Provider != INVALID_HANDLE)
	{
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
	}
	return Plugin_Continue;
}

// =========================================================== //