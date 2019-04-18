// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyHTTP_included_
#endinput
#endif
#define _ProxyHTTP_included_

// =========================================================== //

methodmap ProxyHTTP < StringMapEx
{
	public ProxyHTTP()
	{
		return view_as<ProxyHTTP>(new StringMapEx());
	}
	
	public void SetUrl(char[] url)
	{
		this.SetString("url", url);
	}
	
	public void GetUrl(char[] buffer, int maxlength)
	{
		this.GetString("url", buffer, maxlength);
	}
	
	public void SetName(char[] name)
	{
		this.SetString("name", name);
	}
	
	public void GetName(char[] buffer, int maxlength)
	{
		this.GetString("name", buffer, maxlength);
	}
	
	property Handle Callback
	{
		public get() { return this.GetAny("callback"); }
		public set(Handle fwd) { this.SetValue("callback", fwd); }
	}
	
	property ProxyHTTPParams Params
	{
		public get() { return this.GetAny("params"); }
		public set(ProxyHTTPParams params) { this.SetValue("params", params); }
	}
	
	property ProxyHTTPHeaders Headers
	{
		public get() { return this.GetAny("headers"); }
		public set(ProxyHTTPHeaders headers) { this.SetValue("headers", headers); }
	}
}

// =========================================================== //