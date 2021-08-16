// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyUser_included_
#endinput
#endif
#define _ProxyUser_included_

// =========================================================== //

methodmap ProxyUser < StringMapEx
{
	public ProxyUser(int client)
	{
		StringMapEx user = new StringMapEx();

		char name[MAX_NAME_LENGTH];
		GetClientName(client, name, sizeof(name));

		char steamId2[32];
		if (!GetClientAuthId(client, AuthId_Steam2, steamId2, sizeof(steamId2)))
		{
			steamId2 = "Unknown";
		}

		char steamId64[24];
		if (!GetClientAuthId(client, AuthId_SteamID64, steamId64, sizeof(steamId64)))
		{
			steamId64 = "Unknown";
		}

		char ipAddress[24];
		GetClientIP(client, ipAddress, sizeof(ipAddress));

		user.SetString("name", name);
		user.SetString("steamid2", steamId2);
		user.SetString("steamid64", steamId64);
		user.SetString("ipaddress", ipAddress);
		user.SetValue("userid", GetClientUserId(client));
		return view_as<ProxyUser>(user);
	}

	property int UserId
	{
		public get()
		{
			return this.GetInt("userid");
		}
	}

	property int Client 
	{
		public get()
		{
			return GetClientOfUserId(this.UserId);
		}
	}

	public void GetName(char[] buffer, int maxlength)
	{
		this.GetString("name", buffer, maxlength);
	}

	public void GetSteamId2(char[] buffer, int maxlength)
	{
		this.GetString("steamid2", buffer, maxlength);
	}

	public void GetSteamId64(char[] buffer, int maxlength)
	{
		this.GetString("steamid64", buffer, maxlength);
	}

	public void GetIPAddress(char[] buffer, int maxlength)
	{
		this.GetString("ipaddress", buffer, maxlength);
	}
}

// =========================================================== //