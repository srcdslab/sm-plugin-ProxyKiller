// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCache_included_
#endinput
#endif
#define _ProxyCache_included_

// =========================================================== //

enum CacheMode
{
	CM_None = 0,
	CM_MySQL
};

// =========================================================== //

methodmap ProxyCache < StringMapEx
{
	public ProxyCache(CacheMode mode, any hndl)
	{
		StringMapEx cacheObj = new StringMapEx();
		cacheObj.SetValue("hndl", hndl);
		cacheObj.SetValue("mode", mode);
		return view_as<ProxyCache>(cacheObj);
	}

	property any Hndl
	{
		public get() { return this.GetAny("hndl"); }
	}

	// TODO: Maybe change type name to avoid collisions
	property CacheMode Mode
	{
		public get() { return this.GetAny("mode"); }
	}
}

// =========================================================== //