// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyConfig_included_
#endinput
#endif
#define _ProxyConfig_included_

// =========================================================== //

methodmap ProxyConfig < StringMapEx
{
	public ProxyConfig(StringMap keys, ProxyService service)
	{
		StringMapEx config = new StringMapEx();
		config.SetValue("keys", keys);
		config.SetValue("service", service);
		return view_as<ProxyConfig>(config);
	}

	property StringMap Keys
	{
		public get() { return this.GetAny("keys"); }
	}

	property ProxyService Service
	{
		public get() { return this.GetAny("service"); }
	}
}

// =========================================================== //