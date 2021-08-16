// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyServiceContext_included_
#endinput
#endif
#define _ProxyServiceContext_included_

// =========================================================== //

methodmap ProxyServiceContext < StringMapEx
{
	public ProxyServiceContext()
	{
		return view_as<ProxyServiceContext>(new StringMapEx());
	}
	
	property ProxyUser User 
	{
		public get() { return this.GetAny("user"); }
		public set(ProxyUser user) { this.SetValue("user", user); }
	}
	
	property ProxyService Service
	{
		public get() { return this.GetAny("service"); }
		public set(ProxyService service) { this.SetValue("service", service); }
	}
	
	public void Dispose()
	{
		delete this.User;

		if (this.Service != null)
		{
			this.Service.Dispose();
		}

		delete this;
	}
}

// =========================================================== //