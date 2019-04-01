// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCache_included_
#endinput
#endif
#define _ProxyCache_included_

// =========================================================== //

#include <ProxyKiller/ProxyCacheMySQL>
#include <ProxyKiller/ProxyCacheSQLite>

// =========================================================== //

enum CacheMode
{
	CM_MySQL = 0,
	CM_SQLite
};

// =========================================================== //

methodmap ProxyCache < JSON_Object
{
	public ProxyCache(CacheMode mode)
	{
		JSON_Object cacheObj = new JSON_Object(false);
		cacheObj.SetHandle("cache", null);
		cacheObj.SetInt("mode", view_as<int>(mode));
		
		switch (mode)
		{
			case CM_MySQL:
			{
				ProxyCacheMySQL cache = new ProxyCacheMySQL();
				cache.Initialize();

				cacheObj.SetHandle("cache", cache);
				return view_as<ProxyCache>(cacheObj);
			}
			case CM_SQLite:
			{
				ProxyCacheSQLite cache = new ProxyCacheSQLite();
				cache.Initialize();
				
				cacheObj.SetHandle("cache", cache);
				return view_as<ProxyCache>(cacheObj);
			}
		}
		
		return null;
	}
	
	property any Cache 
	{
		public get() { return this.GetHandle("cache"); }
	}

	property CacheMode Mode
	{
		public get() { return view_as<CacheMode>(this.GetInt("mode")); }
	}

	public void TryCache(ProxyUser pUser, ProxyService service, any result)
	{
		switch (this.Mode)
		{
			case CM_MySQL:
			{
				ProxyCacheMySQL cache = this.Cache;
				cache.TryCache(pUser, service, result, MySQL_OnCached);
			}
			case CM_SQLite:
			{
				ProxyCacheSQLite cache = this.Cache;
				cache.TryCache(pUser, service, result, SQLite_OnCached);
			}
		}
	}
	
	public void TryGet(ProxyUser pUser, ProxyService service)
	{
		switch (this.Mode)
		{
			case CM_MySQL:
			{
				ProxyCacheMySQL cache = this.Cache;
				cache.TryGet(pUser, service, MySQL_OnCache);
			}
			case CM_SQLite:
			{
				ProxyCacheSQLite cache = this.Cache;
				cache.TryGet(pUser, service, SQLite_OnCache);
			}
		}
	}
}

// =========================================================== //