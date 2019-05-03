// =========================================================== //

ConVar gCV_Enable = null;
ConVar gCV_IgnoreAppOwners = null;

ConVar gCV_PunishmentMsg = null;
ConVar gCV_PunishmentLog = null;
ConVar gCV_PunishmentType = null;

ConVar gCV_CacheMode = null;
ConVar gCV_CacheLifetime = null;

// =========================================================== //

void CreateConVars()
{
	gCV_Enable = CreateConVar("ProxyKiller_Enable", "1", "Enable/disable ProxyKiller\n0 = Disable - 1 = Enable", _, true, 0.0, true, 1.0);
	gCV_IgnoreAppOwners = CreateConVar("ProxyKiller_IgnoreAppOwners", "", "Ignore owners of these appids when checking for proxies\nChecking will occur if a client does not have any of these appids\nSeparate appids by a comma ex: \"123, 4444\"");
	
	gCV_PunishmentMsg = CreateConVar("ProxyKiller_PunishmentMsg", "VPNs and Proxies are not tolerated on this server", "Message to display to clients who were punished");
	gCV_PunishmentLog = CreateConVar("ProxyKiller_PunishmentLog", "{steamid2} with ip {ip} was found to be using a proxy or a vpn", "Message to apply to logs, requires \"log\" in PunishmentMode");
	gCV_PunishmentType = CreateConVar("ProxyKiller_PunishmentMode", "1", "Type of punishment to apply to clients\n1 = Log\n2 = Kick\n3 = Log & Kick\n4 = Ban\n5 = Log & Ban", _, true, 1.0, true, 5.0);

	gCV_CacheMode = CreateConVar("ProxyKiller_CacheMode", "1", "Caching mode used for ProxyKiller\n0 = Disabled\n1 = MySQL", _, true, 0.0, true, 1.0);
	gCV_CacheLifetime = CreateConVar("ProxyKiller_CacheLifetime", "43200", "Time in second(s) when to invalidate cache entries and re-query ip addresses\nIt is recommended that you set this to at least 1 hour (3600 seconds)", _, true, 0.0, false);
}

// =========================================================== //