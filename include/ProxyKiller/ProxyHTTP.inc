// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyHTTP_included_
#endinput
#endif
#define _ProxyHTTP_included_

// =========================================================== //

/**
 * Types of ProxyHTTP methods available
 */
enum ProxyHTTPMethod
{
    HTTPMethod_GET,		/**< Do GET request */
    HTTPMethod_HEAD,	/**< DO HEAD request */
    HTTPMethod_POST,	/**< Do POST request */
    HTTPMethod_PUT,		/**< Do PUT request */
    HTTPMethod_DELETE,	/**< Do DELETE request */
    HTTPMethod_OPTIONS,	/**< Do OPTIONS request */
    HTTPMethod_PATCH,	/**< Do PATCH request */
	HTTPMethod_COUNT
};

// =========================================================== //

methodmap ProxyHTTP < StringMapEx
{
	public ProxyHTTP(char[] url, ProxyHTTPMethod method, bool isPersistent = false)
	{
		StringMapEx http = new StringMapEx();
		http.SetString("url", url);
		http.SetValue("method", method);
		http.SetValue("isPersistent", isPersistent);
		http.SetValue("params", new ProxyHTTPParams());
		http.SetValue("headers", new ProxyHTTPHeaders());
		return view_as<ProxyHTTP>(http);
	}

	public void GetUrl(char[] buffer, int maxlength)
	{
		this.GetString("url", buffer, maxlength);
	}

	public void SetRawBody(char[] body, char[] type = "application/json")
	{
		this.SetString("rawbody", body);
		this.SetString("rawbody_type", type);
	}
	
	public void GetRawBody(char[] buffer, int maxlength)
	{
		this.GetString("rawbody", buffer, maxlength);
	}
	
	public void GetRawBodyType(char[] buffer, int maxlength)
	{
		this.GetString("rawbody_type", buffer, maxlength);
	}

	property bool IsPersistent
	{
		public get() { return this.GetBool("isPersistent"); }
	}

	property Handle Callback
	{
		public get() { return this.GetAny("callback"); }
		public set(Handle fwd) { this.SetValue("callback", fwd); }
	}
	
	property ProxyHTTPParams Params
	{
		public get() { return this.GetAny("params"); }
	}

	property ProxyHTTPHeaders Headers
	{
		public get() { return this.GetAny("headers"); }
	}

	property ProxyHTTPResponse Response
	{
		public get() { return this.GetAny("response"); }
		public set(ProxyHTTPResponse response) { this.SetValue("response", response); }
	}

	property ProxyHTTPMethod Method
	{
		public get() { return this.GetAny("method"); }
	}

	public void Dispose()
	{
		delete this.Callback;
		delete this.Response;

		if (!this.IsPersistent)
		{
			delete this.Params;
			delete this.Headers;
			delete this;
		}
	}
}

// =========================================================== //