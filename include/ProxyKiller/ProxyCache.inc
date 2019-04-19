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

// TODO: Figure out a good way to pass SQL callbacks etc...
methodmap ProxyCache < StringMapEx
{
	public ProxyCache(CacheMode mode)
	{
		StringMapEx cacheObj = new StringMapEx();
		cacheObj.SetValue("mode", mode);
		
		switch (mode)
		{
			case CM_MySQL:
			{
				ProxyCacheMySQL cache = new ProxyCacheMySQL();
				cache.Initialize();

				cacheObj.SetValue("cache", cache);
				return view_as<ProxyCache>(cacheObj);
			}
			case CM_SQLite:
			{
				ProxyCacheSQLite cache = new ProxyCacheSQLite();
				cache.Initialize();
				
				cacheObj.SetValue("cache", cache);
				return view_as<ProxyCache>(cacheObj);
			}
		}

		return null;
	}
	
	property any Cache 
	{
		public get() { return this.GetAny("cache"); }
	}

	property CacheMode Mode
	{
		public get() { return view_as<CacheMode>(this.GetInt("mode")); }
	}

	public void TryGet(ProxyUser pUser, ProxyService service)
	{
		switch (this.Mode)
		{
			case CM_MySQL:
			{
				ProxyCacheMySQL cache = this.Cache;

				Function callback = GetFunctionByName(INVALID_HANDLE, "MySQL_OnCache");
				cache.TryGet(pUser, service, view_as<SQLQueryCallback>(callback));
			}
			case CM_SQLite:
			{
				ProxyCacheSQLite cache = this.Cache;

				Function callback = GetFunctionByName(INVALID_HANDLE, "SQLite_OnCache");
				cache.TryGet(pUser, service, view_as<SQLQueryCallback>(callback));
			}
		}
	}

	public void TryCache(ProxyUser pUser, ProxyService service, any result)
	{
		switch (this.Mode)
		{
			case CM_MySQL:
			{
				ProxyCacheMySQL cache = this.Cache;
				
				Function callback = GetFunctionByName(INVALID_HANDLE, "MySQL_OnCached");
				cache.TryCache(pUser, service, result, view_as<SQLQueryCallback>(callback));
			}
			case CM_SQLite:
			{
				ProxyCacheSQLite cache = this.Cache;
				
				Function callback = GetFunctionByName(INVALID_HANDLE, "SQLite_OnCached");
				cache.TryCache(pUser, service, result, view_as<SQLQueryCallback>(callback));
			}
		}
	}
}

// =========================================================== //