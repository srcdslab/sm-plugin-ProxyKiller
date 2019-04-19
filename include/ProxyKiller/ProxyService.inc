// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyService_included_
#endinput
#endif
#define _ProxyService_included_

// =========================================================== //

#define MAX_SERVICE_NAME_LENGTH 128

// =========================================================== //

methodmap ProxyService < ProxyHTTP
{
	public ProxyService(bool isPersistent = false)
	{
		StringMapEx service = new StringMapEx();
		service.SetValue("isPersistent", isPersistent);
		service.SetValue("params", new ProxyHTTPParams());
		service.SetValue("headers", new ProxyHTTPHeaders());
		
		return view_as<ProxyService>(service);
	}
	
	public void SetToken(char[] token)
	{
		this.SetString("token", token);
	}
	
	public void GetToken(char[] buffer, int maxlength)
	{
		this.GetString("token", buffer, maxlength);
	}
	
	public void SetTokenValue(char[] tokenValue)
	{
		this.SetString("token_value", tokenValue);
	}
	
	public void GetTokenValue(char[] buffer, int maxlength)
	{
		this.GetString("token_value", buffer, maxlength);
	}

	property ProxyServiceResponse Response
	{
		public get() { return this.GetAny("response"); }
		public set(ProxyServiceResponse response) { this.SetValue("response", response); }
	}
}

// =========================================================== //