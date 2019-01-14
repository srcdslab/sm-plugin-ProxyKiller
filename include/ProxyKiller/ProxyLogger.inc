// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyLogger_included_
#endinput
#endif
#define _ProxyLogger_included_

// =========================================================== //

#define DEFAULT_LOGGER_PATH "logs/ProxyKiller.log"
#define MAX_LOG_MESSAGE_BUFFER 512

// =========================================================== //

methodmap ProxyLogger < JSON_Object
{
	public ProxyLogger()
	{
		char loggerPath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, loggerPath, sizeof(loggerPath), DEFAULT_LOGGER_PATH);
		
		JSON_Object loggerObj = new JSON_Object();
		loggerObj.SetString("file", loggerPath);

		return view_as<ProxyLogger>(loggerObj);
	}
	
	public void GetFile(char[] buffer, int maxlength)
	{
		this.GetString("file", buffer, maxlength);
	}
	
	public void WriteAndClose(char[] buffer)
	{
		char loggerPath[PLATFORM_MAX_PATH];
		this.GetFile(loggerPath, sizeof(loggerPath));
		
		File file = OpenFile(loggerPath, "a");
		LogToOpenFile(file, buffer);
		file.Close();
	}
	
	public void LogLine(char[] format, any ...)
	{
		char buffer[MAX_LOG_MESSAGE_BUFFER];
		VFormat(buffer, sizeof(buffer), format, 3);
		this.WriteAndClose(buffer);
	}
}

// =========================================================== //