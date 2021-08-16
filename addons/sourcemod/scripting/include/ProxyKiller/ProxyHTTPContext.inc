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

	property any Data
	{
		public get() { return this.GetAny("data"); }
		public set(any data) { this.SetValue("data", data); }
	}
	
	public void Dispose()
	{
		if (this.HTTP != null)
		{
			this.HTTP.Dispose();
		}

		delete this;
	}
}

// =========================================================== //