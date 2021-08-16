// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyConfig_included_
#endinput
#endif
#define _ProxyConfig_included_

// =========================================================== //

methodmap ProxyConfig < StringMapEx
{
	public ProxyConfig(StringMap vars, ProxyService service)
	{
		StringMapEx config = new StringMapEx();
		config.SetValue("vars", vars);
		config.SetValue("service", service);
		return view_as<ProxyConfig>(config);
	}

	property StringMap Vars
	{
		public get() { return this.GetAny("vars"); }
	}

	property ProxyService Service
	{
		public get() { return this.GetAny("service"); }
	}
}

// =========================================================== //