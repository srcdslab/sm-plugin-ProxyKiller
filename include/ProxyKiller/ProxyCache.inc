// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCache_included_
#endinput
#endif
#define _ProxyCache_included_

// =========================================================== //

enum ProxyCacheMode
{
	CM_None = 0,
	CM_MySQL,
	CM_COUNT
};

// =========================================================== //

methodmap ProxyCache < StringMapEx
{
	public ProxyCache(ProxyCacheMode mode, Handle hndl = null)
	{
		StringMapEx cacheObj = new StringMapEx();
		cacheObj.SetValue("hndl", hndl);
		cacheObj.SetValue("mode", mode);
		return view_as<ProxyCache>(cacheObj);
	}

	property Handle Hndl
	{
		public get() { return this.GetAny("hndl"); }
	}

	property ProxyCacheMode Mode
	{
		public get() { return this.GetAny("mode"); }
	}
}

// =========================================================== //