// =========================================================== //

CacheMode GetCachingMethod()
{
	return view_as<CacheMode>(gCV_CacheMode.IntValue);
}

void DetermineAndDoCachingStrategy(ProxyUser pUser)
{
	Call_ProxyKiller_OnCheckClient(pUser);
	g_Cache.TryGet(pUser, g_Config.Service);
}

// =========================================================== //