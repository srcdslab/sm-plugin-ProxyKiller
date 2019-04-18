// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyUser_included_
#endinput
#endif
#define _ProxyUser_included_

// =========================================================== //

methodmap ProxyUser < StringMapEx
{
	public ProxyUser(int userid)
	{
		StringMapEx proxyUser = new StringMapEx();
		proxyUser.SetValue("userid", userid);
		return view_as<ProxyUser>(proxyUser);
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
	
	public void SetSteamId2(const char[] steamId2)
	{
		this.SetString("steamid2", steamId2);
	}
	
	public void SetIPAddress(const char[] ipAddress)
	{
		this.SetString("ipaddress", ipAddress);
	}
	
	public void GetSteamId2(char[] buffer, int maxlength)
	{
		this.GetString("steamid2", buffer, maxlength);
	}

	public void GetIPAddress(char[] buffer, int maxlength)
	{
		this.GetString("ipaddress", buffer, maxlength);
	}
	
	public void GetAndSetSteamId2()
	{
		char steamId2[32];
		if (!GetClientAuthId(this.Client, AuthId_Steam2, steamId2, sizeof(steamId2)))
		{
			strcopy(steamId2, sizeof(steamId2), "Unknown");
		}
		
		this.SetSteamId2(steamId2);
	}
	
	public void GetAndSetIPAddress()
	{
		char ipAddress[24];
		if (!GetClientIP(this.Client, ipAddress, sizeof(ipAddress)))
		{
			strcopy(ipAddress, sizeof(ipAddress), "Unknown");
		}
		
		this.SetIPAddress(ipAddress);
	}
}

// =========================================================== //