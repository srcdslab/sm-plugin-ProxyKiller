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
	public ProxyService(char[] url, ProxyHTTPMethod method, char[] name, ProxyServiceResponse response)
	{
		ProxyHTTP service = new ProxyHTTP(url, method, true);
		service.SetString("name", name);
		service.SetValue("expected_response", response);
		return view_as<ProxyService>(service);
	}

	public bool GetName(char[] buffer, int maxlength)
	{
		return this.GetString("name", buffer, maxlength);
	}

	property ProxyServiceResponse ExpectedResponse
	{
		public get() { return this.GetAny("expected_response"); }
	}
}

// =========================================================== //