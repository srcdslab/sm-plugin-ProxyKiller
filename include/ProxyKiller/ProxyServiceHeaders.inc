// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyServiceHeaders_included_
#endinput
#endif
#define _ProxyServiceHeaders_included_

// =========================================================== //

methodmap ProxyServiceHeaders < JSON_Object
{
	public ProxyServiceHeaders()
	{
		return view_as<ProxyServiceHeaders>(new JSON_Object(false));
	}
	
	public void AddHeader(char[] header, char[] value)
	{
		this.SetString(header, value);
	}
}

// =========================================================== //