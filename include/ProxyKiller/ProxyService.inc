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
	public ProxyService()
	{
		return view_as<ProxyService>(new ProxyHTTP(true));
	}

	public void SetName(char[] name)
	{
		this.SetString("name", name);
	}

	public bool GetName(char[] buffer, int maxlength)
	{
		return this.GetString("name", buffer, maxlength);
	}

	property ProxyServiceResponse ExpectedResponse
	{
		public get() { return this.GetAny("expected_response"); }
		public set(ProxyServiceResponse response) { this.SetValue("expected_response", response); }
	}
}

// =========================================================== //