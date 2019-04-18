// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyHTTPHeaders_included_
#endinput
#endif
#define _ProxyHTTPHeaders_included_

// =========================================================== //

methodmap ProxyHTTPHeaders < StringMapEx
{
	public ProxyHTTPHeaders()
	{
		return view_as<ProxyHTTPHeaders>(new StringMapEx());
	}
	
	public void AddHeader(char[] header, char[] value)
	{
		this.SetString(header, value);
	}
}

// =========================================================== //