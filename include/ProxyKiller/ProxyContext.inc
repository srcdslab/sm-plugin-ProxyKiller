// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyContext_included_
#endinput
#endif
#define _ProxyContext_included_

// =========================================================== //

methodmap ProxyContext < JSON_Object
{
	public ProxyContext()
	{
		return view_as<ProxyContext>(new JSON_Object(false));
	}
	
	property ProxyUser User 
	{
		public get() { return view_as<ProxyUser>(this.GetHandle("user")); }
		public set(ProxyUser user) { this.SetHandle("user", user); }
	}
	
	property ProxyService Service
	{
		public get() { return view_as<ProxyService>(this.GetHandle("service")); }
		public set(ProxyService service) { this.SetHandle("service", service); }
	}
}

// =========================================================== //