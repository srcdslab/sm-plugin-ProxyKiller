// =========================================================== //

static GlobalForward H_OnCache = null;
static GlobalForward H_OnRules = null;
static GlobalForward H_OnConfig = null;
static GlobalForward H_OnLogger = null;
static GlobalForward H_OnValidClient = null;

static GlobalForward H_DoCheckClient = null;
static GlobalForward H_OnCheckClient = null;

static GlobalForward H_OnClientResult = null;

static GlobalForward H_DoClientResultCache = null;
static GlobalForward H_OnClientResultCache = null;

static GlobalForward H_DoClientPunishment = null;
static GlobalForward H_OnClientPunishment = null;

// =========================================================== //

void CreateForwards()
{
	H_OnCache = new GlobalForward("ProxyKiller_OnCache", ET_Ignore);
	H_OnRules = new GlobalForward("ProxyKiller_OnRules", ET_Ignore);
	H_OnConfig = new GlobalForward("ProxyKiller_OnConfig", ET_Ignore);
	H_OnLogger = new GlobalForward("ProxyKiller_OnLogger", ET_Ignore);
	H_OnValidClient = new GlobalForward("ProxyKiller_OnValidClient", ET_Ignore, Param_Cell);

	H_DoCheckClient = new GlobalForward("ProxyKiller_DoCheckClient", ET_Hook, Param_Cell);
	H_OnCheckClient = new GlobalForward("ProxyKiller_OnCheckClient", ET_Ignore, Param_Cell);

	H_OnClientResult = new GlobalForward("ProxyKiller_OnClientResult", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);

	H_DoClientResultCache = new GlobalForward("ProxyKiller_DoClientResultCache", ET_Hook, Param_Cell, Param_Cell);
	H_OnClientResultCache = new GlobalForward("ProxyKiller_OnClientResultCache", ET_Ignore, Param_Cell, Param_Cell);

	H_DoClientPunishment = new GlobalForward("ProxyKiller_DoClientPunishment", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	H_OnClientPunishment = new GlobalForward("ProxyKiller_OnClientPunishment", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
}

// =========================================================== //

void Call_OnCache()
{
	Call_StartForward(H_OnCache);
	Call_Finish();
}

void Call_OnRules()
{
	Call_StartForward(H_OnRules);
	Call_Finish();
}

void Call_OnConfig()
{
	Call_StartForward(H_OnConfig);
	Call_Finish();
}

void Call_OnLogger()
{
	Call_StartForward(H_OnLogger);
	Call_Finish();
}

void Call_OnValidClient(int client)
{
	Call_StartForward(H_OnValidClient);
	Call_PushCell(client);
	Call_Finish();
}

bool Call_DoCheckClient(int client)
{
	Action retval = Plugin_Continue;
	Call_StartForward(H_DoCheckClient);
	Call_PushCell(client);
	Call_Finish(retval);
	return retval == Plugin_Continue;
}

void Call_OnCheckClient(ProxyUser pUser)
{
	Call_StartForward(H_OnCheckClient);
	Call_PushCell(pUser);
	Call_Finish();
}

void Call_OnClientResult(ProxyUser pUser, bool result, bool fromCache)
{
	Call_StartForward(H_OnClientResult);
	Call_PushCell(pUser);
	Call_PushCell(result);
	Call_PushCell(fromCache);
	Call_Finish();
}

bool Call_DoClientResultCache(ProxyUser pUser, bool result)
{
	Action retval = Plugin_Continue;
	Call_StartForward(H_DoClientResultCache);
	Call_PushCell(pUser);
	Call_PushCell(result);
	Call_Finish(retval);
	return retval == Plugin_Continue;
}

void Call_OnClientResultCache(ProxyUser pUser, bool result)
{
	Call_StartForward(H_OnClientResultCache);
	Call_PushCell(pUser);
	Call_PushCell(result);
	Call_Finish();
}

bool Call_DoClientPunishment(ProxyUser pUser, bool fromCache, bool fromBlacklist)
{
	Action retval = Plugin_Continue;
	Call_StartForward(H_DoClientPunishment);
	Call_PushCell(pUser);
	Call_PushCell(fromCache);
	Call_PushCell(fromBlacklist);
	Call_Finish(retval);
	return retval == Plugin_Continue;
}

void Call_OnClientPunishment(ProxyUser pUser, bool fromCache, bool fromBlacklist)
{
	Call_StartForward(H_OnClientPunishment);
	Call_PushCell(pUser);
	Call_PushCell(fromCache);
	Call_PushCell(fromBlacklist);
	Call_Finish();
}

// =========================================================== //
