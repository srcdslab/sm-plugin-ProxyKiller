// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyHTTP_included_
#endinput
#endif
#define _ProxyHTTP_included_

// =========================================================== //

enum ProxyHTTPMethod
{
	HTTPMethod_GET,
	HTTPMethod_POST
};

// =========================================================== //

methodmap ProxyHTTP < StringMapEx
{
	public ProxyHTTP(bool isPersistent = false)
	{
		StringMapEx http = new StringMapEx();
		http.SetValue("isPersistent", isPersistent);
		http.SetValue("params", new ProxyHTTPParams());
		http.SetValue("headers", new ProxyHTTPHeaders());
		return view_as<ProxyHTTP>(http);
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
		public set(ProxyHTTPMethod method) { this.SetValue("method", method); }
	}
	
	public void Cleanup()
	{
		if (this.Callback != null)
		{
			delete this.Callback;
		}

		if (this.Response != null)
		{
			delete this.Response;
		}

		if (!this.IsPersistent)
		{
			if (this.Params != null)
			{
				delete this.Params;
			}
			if (this.Headers != null)
			{
				delete this.Headers;
			}

			delete this;
		}
	}
}

// =========================================================== //