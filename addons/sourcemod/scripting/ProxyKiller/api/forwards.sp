// =========================================================== //

static Handle H_OnCache = null;
static Handle H_OnRules = null;
static Handle H_OnConfig = null;
static Handle H_OnLogger = null;
static Handle H_OnValidClient = null;

static Handle H_DoCheckClient = null;
static Handle H_OnCheckClient = null;

static Handle H_OnClientResult = null;

static Handle H_DoClientResultCache = null;
static Handle H_OnClientResultCache = null;

static Handle H_DoClientPunishment = null;
static Handle H_OnClientPunishment = null;

// =========================================================== //

void CreateForwards()
{
	H_OnCache = CreateGlobalForward("ProxyKiller_OnCache", ET_Ignore);
	H_OnRules = CreateGlobalForward("ProxyKiller_OnRules", ET_Ignore);
	H_OnConfig = CreateGlobalForward("ProxyKiller_OnConfig", ET_Ignore);
	H_OnLogger = CreateGlobalForward("ProxyKiller_OnLogger", ET_Ignore);
	H_OnValidClient = CreateGlobalForward("ProxyKiller_OnValidClient", ET_Ignore, Param_Cell);

	H_DoCheckClient = CreateGlobalForward("ProxyKiller_DoCheckClient", ET_Hook, Param_Cell);
	H_OnCheckClient = CreateGlobalForward("ProxyKiller_OnCheckClient", ET_Ignore, Param_Cell);

	H_OnClientResult = CreateGlobalForward("ProxyKiller_OnClientResult", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);

	H_DoClientResultCache = CreateGlobalForward("ProxyKiller_DoClientResultCache", ET_Hook, Param_Cell, Param_Cell);
	H_OnClientResultCache = CreateGlobalForward("ProxyKiller_OnClientResultCache", ET_Ignore, Param_Cell, Param_Cell);

	H_DoClientPunishment = CreateGlobalForward("ProxyKiller_DoClientPunishment", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	H_OnClientPunishment = CreateGlobalForward("ProxyKiller_OnClientPunishment", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
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
