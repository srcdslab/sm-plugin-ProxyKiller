// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyLogger_included_
#endinput
#endif
#define _ProxyLogger_included_

// =========================================================== //

enum (<<= 1)
{
	SPEWMODE_LOG = 1 << 0,
	SPEWMODE_CHAT = 1 << 1
};

enum (<<= 1)
{
	SPEWLEVEL_ERRORS = 1 << 0,
	SPEWLEVEL_INFO = 1 << 1,
	SPEWLEVEL_DEBUG = 1 << 2
};

// =========================================================== //

methodmap ProxyLogger < StringMapEx
{
	public ProxyLogger(int spewMode, int spewLevel)
	{
		StringMapEx logger = new StringMapEx();
		logger.SetValue("spewmode", spewMode);
		logger.SetValue("spewlevel", spewLevel);
		return view_as<ProxyLogger>(logger);
	}

	property int SpewMode 
	{
		public get() { return this.GetInt("spewmode"); }
	}
	
	property int SpewLevel
	{
		public get() { return this.GetInt("spewlevel"); }
	}

	public void DoSpew(char[] format, any ...)
	{
		if (this.SpewMode == 0) return;

		char buffer[600];
		VFormat(buffer, sizeof(buffer), format, 3); // this has to be a bug

		if (this.SpewMode & SPEWMODE_LOG)
		{
			// TODO: Pass in SpewLevel
			// And do LogError for errors...
			LogMessage("%s", buffer);
		}

		if (this.SpewMode & SPEWMODE_CHAT)
		{
			PrintToChatAll("%s", buffer);
		}
	}

	public void InfoMessage(char[] format, any ...)
	{
		if (this.SpewLevel & SPEWLEVEL_INFO)
		{
			char buffer[512];
			VFormat(buffer, sizeof(buffer), format, 2);
			
			this.DoSpew("[I]: %s", buffer);
		}
	}
	
	public void ErrorMessage(char[] format, any ...)
	{
		if (this.SpewLevel & SPEWLEVEL_ERRORS)
		{
			char buffer[512];
			VFormat(buffer, sizeof(buffer), format, 2);
			
			this.DoSpew("[!] %s", buffer);
		}
	}
	
	public void DebugMessage(char[] format, any ...)
	{
		if (this.SpewLevel & SPEWLEVEL_DEBUG)
		{
			char buffer[512];
			VFormat(buffer, sizeof(buffer), format, 2);

			this.DoSpew("[~] %s", buffer);
		}
	}
}

// =========================================================== //