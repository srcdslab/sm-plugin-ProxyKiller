// =========================================================== //

CacheMode GetCachingMethod()
{
	return view_as<CacheMode>(gCV_CacheMode.IntValue);
}

void DetermineAndDoCachingStrategy(ProxyUser pUser)
{
	g_Cache.TryGet(pUser, g_Service);
}

// =========================================================== //