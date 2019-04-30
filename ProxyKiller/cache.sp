// =========================================================== //

#define MySQL(%1) view_as<ProxyCacheMySQL>(%1)

// =========================================================== //

// REEEEEE WE CANNOT CALL THE METHOD FROM THE DERIVED CLASS!! :(
ProxyCache CreateCache(int mode)
{
	ProxyCache cache = null;
	CacheMode cm = view_as<CacheMode>(mode);
	
	switch (cm)
	{
		case CM_MySQL:
		{
			g_Logger.PrintFrame("MySQL");
			cache = new ProxyCacheMySQL();
			MySQL(cache).Initialize();
		}
	}

	return cache;
}

void TryGetCache(ProxyUser pUser)
{
	Call_OnCheckClient(pUser);
	
	switch (g_Cache.Mode)
	{
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