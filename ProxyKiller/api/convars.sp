// =========================================================== //

ConVar gCV_Enable = null;
ConVar gCV_IgnoreAppOwners = null;

ConVar gCV_PunishmentType = null;
ConVar gCV_PunishmentMessage = null;
ConVar gCV_PunishmentLogFormat = null;

ConVar gCV_CacheMode = null;
ConVar gCV_CacheLifetime = null;

// =========================================================== //

void CreateConVars()
{
	gCV_Enable = CreateConVar("ProxyKiller_Enable", "1", "Enable/disable ProxyKiller\n0 = Disable - 1 = Enable", _, true, 0.0, true, 1.0);
	gCV_IgnoreAppOwners = CreateConVar("ProxyKiller_IgnoreAppOwners", "", "Ignore owners of these appids when checking for proxies\nChecking will occur if a client does not have any of these appids\nSeparate appids by a comma ex: \"123, 4444\"");

	gCV_PunishmentType = CreateConVar("ProxyKiller_PunishmentMode", "0", "Type of punishment to apply to clients\n0 = Kick\n1 = Ban", _, true, 1.0, true, 1.0);
	gCV_PunishmentMessage = CreateConVar("ProxyKiller_PunishmentMessage", "VPNs and Proxies are not tolerated on this server!", "Message to display to clients who were punished");
	gCV_PunishmentLogFormat = CreateConVar("ProxyKiller_PunishmentLogFormat", "{steamid2} with ip {ip} was found to be using a proxy or a vpn", "Message to apply to logs, set empty to disable entirely");

	gCV_CacheMode = CreateConVar("ProxyKiller_CacheMode", "1", "Caching mode used for ProxyKiller\n0 = Disabled\n1 = MySQL", _, true, 0.0, true, 1.0);
	gCV_CacheLifetime = CreateConVar("ProxyKiller_CacheLifetime", "43200", "Time in second(s) when to invalidate cache entries and re-query ip addresses\nIt is recommended that you set this to at least 1 hour (3600 seconds)", _, true, 0.0, false);
}

// =========================================================== //