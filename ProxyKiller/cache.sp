// =========================================================== //

#define MySQL(%1) view_as<ProxyCacheMySQL>(%1)

// =========================================================== //

// REEEEEE WE CANNOT CALL THE METHOD FROM THE DERIVED CLASS!! :(
ProxyCache CreateCache(int mode)
{
	int minMode = view_as<int>(CM_None);
	int maxMode = view_as<int>(CM_COUNT) - 1;
	
	if (mode < minMode) mode = 0;
	else if (mode > maxMode) mode = 1;
	
	ProxyCache cache = null;
	CacheMode cm = view_as<CacheMode>(mode);
	
	switch (cm)
	{
		case CM_None:
		{
			g_Logger.PrintFrame("None");
			cache = new ProxyCache(cm, 0);
		}
		case CM_MySQL:
		{
			g_Logger.PrintFrame("MySQL");
			cache = new ProxyCacheMySQL();
		}
	}
	
	cache.Initialize();
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
			MySQL(g_Cache).TryGetCache(pUser, g_Config.Service);
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
			MySQL(g_Cache).TryPushCache(pUser, service, result);
		}
	}
}

// =========================================================== //