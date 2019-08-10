// =========================================================== //

static bool gB_CacheInit = false;

#define MySQL(%1) view_as<ProxyCacheMySQL>(%1)

// =========================================================== //

bool IsCacheInit()
{
	return gB_CacheInit;
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
			g_Logger.PrintFrame("MySQL");
			cache = new ProxyCacheMySQL();
			MySQL(cache).Initialize();
		}
	}

	gB_CacheInit = true;
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
			MySQL(g_Cache).TryGetCache(pUser, g_Config.Service, MySQL_OnCache);
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
			MySQL(g_Cache).TryPushCache(pUser, service, result, MySQL_OnCached);
		}
		default:
		{
			g_Logger.DebugMessage("Cache mode %d has no implementation for TryPushCache", g_Cache.Mode);
		}
	}
}

// =========================================================== //