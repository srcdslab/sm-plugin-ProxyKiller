// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyServiceParams_included_
#endinput
#endif
#define _ProxyServiceParams_included_

// =========================================================== //

methodmap ProxyServiceParams < JSON_Object
{
	public ProxyServiceParams()
	{
		return view_as<ProxyServiceParams>(new JSON_Object());
	}
	
	public void AddParam(char[] key, char[] value)
	{
		this.SetString(key, value);
	}
}

// =========================================================== //