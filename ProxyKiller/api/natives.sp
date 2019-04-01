// =========================================================== //

void CreateNatives()
{
	CreateNative("ProxyKiller_CheckClient", Native_CheckClient);
}

// =========================================================== //

public int Native_CheckClient(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int userid = GetClientUserId(client);

	ProxyUser pUser = new ProxyUser(userid);
	pUser.GetAndSetSteamId2();
	pUser.GetAndSetIPAddress();
	DetermineAndDoCachingStrategy(pUser);
}

// =========================================================== //