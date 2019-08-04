// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCache_included_
#endinput
#endif
#define _ProxyCache_included_

// =========================================================== //

/**
 * Types of caching solutions available
 */
enum ProxyCacheMode
{
	CM_None = 0,	/**< No caching */
	CM_MySQL,		/**< Use MySQL */
	CM_COUNT
};

// =========================================================== //

methodmap ProxyCache < StringMapEx
{
	public ProxyCache(ProxyCacheMode mode, any provider = 0)
	{
		StringMapEx cacheObj = new StringMapEx();
		cacheObj.SetValue("mode", mode);
		cacheObj.SetValue("provider", provider);
		return view_as<ProxyCache>(cacheObj);
	}

	property ProxyCacheMode Mode
	{
		public get() { return this.GetAny("mode"); }
	}

	property any Provider
	{
		public get() { return this.GetAny("provider"); }
	}
}

// =========================================================== //