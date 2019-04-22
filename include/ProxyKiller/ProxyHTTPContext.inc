// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyHTTPContext_included_
#endinput
#endif
#define _ProxyHTTPContext_included_

// =========================================================== //

methodmap ProxyHTTPContext < StringMapEx
{
	public ProxyHTTPContext()
	{
		return view_as<ProxyHTTPContext>(new StringMapEx());
	}
	
	property ProxyHTTP HTTP
	{
		public get() { return this.GetAny("http"); }
		public set(ProxyHTTP http) { this.SetValue("http", http); }
	}

	property ProxyHTTPResponse Response
	{
		public get() { return this.GetAny("response"); }
		public set(ProxyHTTPResponse response) { this.SetValue("response", response); }
	}

	property any Data
	{
		public get() { return this.GetAny("data"); }
		public set(any data) { this.SetValue("data", data); }
	}
	
	public void Cleanup()
	{
		if (this.HTTP != null)
		{
			this.HTTP.Cleanup();
		}
		if (this.Response != null)
		{
			delete this.Response;
		}
		
		delete this;
	}
}

// =========================================================== //