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
	int minMode = view_as<int>(CM_None);
	int maxMode = view_as<int>(CM_COUNT) - 1;

	if (mode < minMode) mode = 0;
	else if (mode > maxMode) mode = 1;

	ProxyCache cache = null;
	ProxyCacheMode cm = view_as<ProxyCacheMode>(mode);

	switch (cm)
	{
		case CM_None:
		{
			g_Logger.PrintFrame("None");
			cache = new ProxyCache(cm);
		}
		case CM_MySQL:
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
		case CM_None:
		{
			QueryService(pUser, g_Config.Service);
		}
		case CM_MySQL:
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
		case CM_MySQL:
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