// =========================================================== //

ConVar gCV_Enable = null;
ConVar gCV_IgnoreFlags = null;
ConVar gCV_IgnoreAppOwners = null;

ConVar gCV_PunishmentType = null;
ConVar gCV_PunishmentMessage = null;
ConVar gCV_PunishmentLogFormat = null;
ConVar gCV_PunishmentBanLength = null;

ConVar gCV_DatabaseTablePrefix = null;

ConVar gCV_CacheMode = null;
ConVar gCV_CacheLifetime = null;

ConVar gCV_RulesMode = null;

#if defined _vip_core_included
ConVar gCV_CheckMethod = null;
#endif

// =========================================================== //

void CreateConVars()
{
	gCV_Enable = CreateConVar("ProxyKiller_Enable", "1", "Enable/disable ProxyKiller\n0 = Disable - 1 = Enable", _, true, 0.0, true, 1.0);
	gCV_IgnoreFlags = CreateConVar("ProxyKiller_IgnoreFlags", "", "Ignore clients with these admin flags when checking for proxies\nChecking will occur if a client does not have any of these flags");
	gCV_IgnoreAppOwners = CreateConVar("ProxyKiller_IgnoreAppOwners", "", "Ignore owners of these appids when checking for proxies\nChecking will occur if a client does not have any of these appids\nSeparate appids by a comma ex: \"123, 4444\"");

	gCV_PunishmentType = CreateConVar("ProxyKiller_Punishment_Mode", "1", "Type of punishment to apply to clients\n0 = None\n1 = Kick\n2 = Ban", _, true, 0.0, true, float(Punishment_COUNT - 1));
	gCV_PunishmentMessage = CreateConVar("ProxyKiller_Punishment_Message", "VPNs and Proxies are not tolerated on this server!", "Message to display to clients who were punished");
	gCV_PunishmentLogFormat = CreateConVar("ProxyKiller_Punishment_LogFormat", "{steamid2} with ip {ip} was found to be using a proxy or a vpn", "Message to apply to logs, set empty to disable entirely");
	gCV_PunishmentBanLength = CreateConVar("ProxyKiller_Punishment_BanLength", "10080", "Ban length in minutes to apply when clients are punished and punishment mode is set to \"ban\"", _, true, 0.0);

	gCV_DatabaseTablePrefix = CreateConVar("ProxyKiller_Database_Table_Prefix", "ProxyKiller", "Table prefix used for Cache / Rules (SQL)");

	gCV_CacheMode = CreateConVar("ProxyKiller_Cache_Mode", "1", "Caching mode used for ProxyKiller\n0 = Disabled\n1 = MySQL\n2 = SQLite", _, true, 0.0, true, float(view_as<int>(CacheMode_COUNT) - 1));
	gCV_CacheLifetime = CreateConVar("ProxyKiller_Cache_Lifetime", "43200", "Time in second(s) when to invalidate cache entries and re-query ip addresses\nIt is recommended that you set this to at least 1 hour (3600 seconds)", _, true, 0.0, false);

	gCV_RulesMode = CreateConVar("ProxyKiller_Rules_Mode", "-1", "Rules mode used for ProxyKiller\n-1 = Inherit from cache\n0 = Disabled\n1 = MySQL\n2 = SQLite", _, true, -1.0, true, float(view_as<int>(RulesMode_COUNT) - 1));

	#if defined _vip_core_included
	gCV_CheckMethod = CreateConVar("ProxyKiller_CheckMethod", "1", "When should we start check player\n0 = OnClientPostAdminCheck - 1 = VIP_OnClientLoaded", _, true, 0.0, true, 1.0);
	#endif
}

// =========================================================== //