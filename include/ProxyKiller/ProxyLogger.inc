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

	public bool GetLastFrame(char[] buffer, int maxlength)
	{
		return this.GetString("lastFrame", buffer, maxlength);
	}

	public void DoSpew(int spewType, char[] format, any ...)
	{
		if (this.SpewMode == 0) return;

		char buffer[600];
		VFormat(buffer, sizeof(buffer), format, 4);

		if (this.SpewMode & SPEWMODE_LOG)
		{
			if (spewType == SPEWLEVEL_ERRORS)
			{
				LogError("%s", buffer);
			}
			else
			{
				LogMessage("%s", buffer);
			}
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
			VFormat(buffer, sizeof(buffer), format, 3);
			
			this.DoSpew(SPEWLEVEL_INFO, "[I]: %s", buffer);
		}
	}

	public void ErrorMessage(char[] format, any ...)
	{
		if (this.SpewLevel & SPEWLEVEL_ERRORS)
		{
			char buffer[512];
			VFormat(buffer, sizeof(buffer), format, 3);
			
			this.DoSpew(SPEWLEVEL_ERRORS, "[!] %s", buffer);
		}
	}

	public void DebugMessage(char[] format, any ...)
	{
		if (this.SpewLevel & SPEWLEVEL_DEBUG)
		{
			char buffer[512];
			VFormat(buffer, sizeof(buffer), format, 3);

			char lastFunc[128];
			if (this.GetLastFrame(lastFunc, sizeof(lastFunc)))
			{
				FrameIterator iter = new FrameIterator();
				// 0 = FrameIterator()
				// 1 = ProxyLogger.DebugMessage
				// 2 = Function we got called from
				iter.Next();
				iter.Next();

				char funcName[128];
				iter.GetFunctionName(funcName, sizeof(funcName));

				if (StrEqual(lastFunc, funcName))
				{
					this.DoSpew(SPEWLEVEL_DEBUG, "[~]  - %s", buffer);
				}

				delete iter;
			}
			else
			{
				this.DoSpew(SPEWLEVEL_DEBUG, "[~] %s", buffer);
			}
		}
	}

	public void PrintFrame(char[] info = "")
	{
		if (this.SpewLevel & SPEWLEVEL_DEBUG)
		{
			FrameIterator iter = new FrameIterator();
			// 0 = FrameIterator()
			// 1 = ProxyLogger.PrintFrame
			// 2 = Function we got called from
			iter.Next();
			iter.Next();

			char funcName[128];
			iter.GetFunctionName(funcName, sizeof(funcName));

			char funcPath[PLATFORM_MAX_PATH];
			iter.GetFilePath(funcPath, sizeof(funcPath));

			this.DoSpew(SPEWLEVEL_DEBUG, "[~] %s(%d)::%s(%s)", funcPath, iter.LineNumber, funcName, info);

			this.SetString("lastFrame", funcName);
			delete iter;
		}
	}
}

// =========================================================== //