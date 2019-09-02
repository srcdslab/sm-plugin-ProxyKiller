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
		http.SetValue("persistent", isPersistent);
		http.SetValue("params", new ProxyHTTPParams());
		http.SetValue("headers", new ProxyHTTPHeaders());
		return view_as<ProxyHTTP>(http);
	}

	public void SetRawBody(char[] body, char[] type = "application/json")
	{
		this.SetString("rawbody", body);
		this.SetString("rawbody_type", type);
	}

	public void SetResponseFile(char[] file)
	{
		this.SetString("responsefile", file);
	}

	public void GetUrl(char[] buffer, int maxlength)
	{
		this.GetString("url", buffer, maxlength);
	}

	public void GetRawBody(char[] buffer, int maxlength)
	{
		this.GetString("rawbody", buffer, maxlength);
	}

	public void GetRawBodyType(char[] buffer, int maxlength)
	{
		this.GetString("rawbody_type", buffer, maxlength);
	}

	public void GetResponseFile(char[] buffer, int maxlength)
	{
		this.GetString("responsefile", buffer, maxlength);
	}

	property bool IsPersistent
	{
		public get() { return this.GetBool("persistent"); }
	}

	property bool HasRawBody
	{
		public get() { return this.HasKeyWithString("rawbody"); }
	}

	property bool HasResponseFile
	{
		public get() { return this.HasKeyWithString("responsefile"); }
	}

	property Handle Callback
	{
		public get() { return this.GetAny("callback"); }
		public set(Handle fwd) { this.SetValue("callback", fwd); }
	}

	property ProxyHTTPMethod Method
	{
		public get() { return this.GetAny("method"); }
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