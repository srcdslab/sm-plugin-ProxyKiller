// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCache_included_
#endinput
#endif
#define _ProxyCache_included_

// =========================================================== //

enum CacheMode
{
	CM_None = 0,
	CM_MySQL,
	CM_COUNT
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
	
	public void GetInitialize(char[] buffer, int maxlength)
	{
		this.GetString("initialize_method", buffer, maxlength);
	}
	
	public void Initialize()
	{
		char buf[128];
		this.GetInitialize(buf, sizeof(buf));
		
		Function fCall = GetFunctionByName(null, buf);
		
		if (fCall == INVALID_FUNCTION)
		{
			LogError("No implementation for Initialize");
		}
		else
		{
			Call_StartFunction(null, fCall);
			Call_PushCell(this);
			Call_Finish();
		}
	}
}

// =========================================================== //