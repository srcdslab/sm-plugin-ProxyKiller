// =========================================================== //

ConVar gCV_Enable = null;
ConVar gCV_KickMsg = null;
ConVar gCV_CacheMode = null;
ConVar gCV_CacheLifetime = null;
ConVar gCV_IgnoreAppOwners = null;

// =========================================================== //

void CreateConVars()
{
	gCV_Enable = CreateConVar("ProxyKiller_Enable", "1", "Enable/disable ProxyKiller\n0 = Disable - 1 = Enable", _, true, 0.0, true, 1.0);
	gCV_KickMsg = CreateConVar("ProxyKiller_KickMessage", "Kicked due to proxy usage!", "Message to be sent to clients when they're kicked");
	gCV_CacheMode = CreateConVar("ProxyKiller_CacheMode", "0", "Caching mode used for ProxyKiller\n0 = MySQL\n1 = SQLite", _, true, 0.0, true, 1.0);
	gCV_CacheLifetime = CreateConVar("ProxyKiller_CacheLifetime", "43200", "Time in second(s) when to invalidate cache entries and re-query ip addresses\nIt is recommended that you set this to at least 1 hour (3600 seconds)", _, true, 0.0, false);
	gCV_IgnoreAppOwners = CreateConVar("ProxyKiller_IgnoreAppOwners", "", "Ignore owners of these appids when checking for proxies\nChecking will occur if a client does not have any of these appids\nSeparate appids by a comma ex: \"123, 4444\"");
}

// =========================================================== //