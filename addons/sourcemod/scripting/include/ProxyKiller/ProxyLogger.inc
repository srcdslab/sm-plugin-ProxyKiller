// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyLogger_included_
#endinput
#endif
#define _ProxyLogger_included_

// =========================================================== //

/**
 * Types of logging spewmodes available
 */
enum //(<<= 1)
{
	SPEWMODE_LOG = 1 << 0,		/**< Spew messages to logs */
	SPEWMODE_CHAT = 1 << 1		/**< Spew messages to ingame chat */
}

/**
 * Types of logging spewlevels available
 */
enum //(<<= 1)
{
	SPEWLEVEL_ERROR = 1 << 0,	/**< Spew error messages */
	SPEWLEVEL_INFO = 1 << 1,	/**< Spew info messages */
	SPEWLEVEL_DEBUG = 1 << 2	/**< Spew debugging messages */
}

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

	public bool DoSpew(int spewType, char[] format, any ...)
	{
		if (this.SpewMode == 0) return false;
		if (!(this.SpewLevel & spewType)) return false;

		char buffer[600];
		VFormat(buffer, sizeof(buffer), format, 4);

		if (this.SpewMode & SPEWMODE_LOG)
		{
			if (spewType == SPEWLEVEL_ERROR)
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

		return true;
	}

	public bool InfoMessage(char[] format, any ...)
	{
		char buffer[512];
		VFormat(buffer, sizeof(buffer), format, 3);
		return this.DoSpew(SPEWLEVEL_INFO, "[ INFO  ] %s", buffer);
	}

	public bool ErrorMessage(char[] format, any ...)
	{
		char buffer[512];
		VFormat(buffer, sizeof(buffer), format, 3);
		return this.DoSpew(SPEWLEVEL_ERROR, "[ ERROR ] %s", buffer);
	}

	public bool DebugMessage(char[] format, any ...)
	{
		char buffer[512];
		VFormat(buffer, sizeof(buffer), format, 3);
		return this.DoSpew(SPEWLEVEL_DEBUG, "[ DEBUG ] %s", buffer);
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

			this.DebugMessage("-> %s(%d)::%s(%s)", funcPath, iter.LineNumber, funcName, info);
			delete iter;
		}
	}
}

// =========================================================== //