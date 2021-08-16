// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyHTTPParams_included_
#endinput
#endif
#define _ProxyHTTPParams_included_

// =========================================================== //

methodmap ProxyHTTPParams < StringMapEx
{
	public ProxyHTTPParams()
	{
		return view_as<ProxyHTTPParams>(new StringMapEx());
	}
	
	public void AddParam(char[] key, char[] value)
	{
		this.SetString(key, value);
	}
}

// =========================================================== //