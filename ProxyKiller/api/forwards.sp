// =========================================================== //

static Handle H_OnConfig = null;

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
	H_OnConfig = CreateGlobalForward("ProxyKiller_OnConfig", ET_Ignore, Param_Cell);
	
	H_DoCheckClient = CreateGlobalForward("ProxyKiller_OnCheckClient", ET_Hook, Param_Cell);
	H_OnCheckClient = CreateGlobalForward("ProxyKiller_OnCheckClient", ET_Ignore, Param_Cell);
	
	H_OnClientResult = CreateGlobalForward("ProxyKiller_OnClientResult", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);

	H_DoClientResultCache = CreateGlobalForward("ProxyKiller_DoClientResultCache", ET_Hook, Param_Cell, Param_Cell);
	H_OnClientResultCache = CreateGlobalForward("ProxyKiller_OnClientResultCache", ET_Ignore, Param_Cell, Param_Cell);
	
	H_DoClientPunishment = CreateGlobalForward("ProxyKiller_DoClientPunishment", ET_Hook, Param_Cell, Param_Cell);
	H_OnClientPunishment = CreateGlobalForward("ProxyKiller_OnClientPunishment", ET_Ignore, Param_Cell, Param_Cell);
}

// =========================================================== //

void Call_ProxyKiller_OnConfig(ProxyConfig config)
{
	Call_StartForward(H_OnConfig);
	Call_PushCell(config);
	Call_Finish();
}

Action Call_ProxyKiller_DoCheckClient(int client)
{
	Action retval = Plugin_Continue;
	Call_StartForward(H_DoCheckClient);
	Call_PushCell(client);
	Call_Finish(retval);
	return retval;
}

void Call_ProxyKiller_OnCheckClient(int client)
{
	Call_StartForward(H_OnCheckClient);
	Call_PushCell(client);
	Call_Finish();
}

void Call_ProxyKiller_OnClientResult(ProxyUser pUser, bool result, bool fromCache)
{
	Call_StartForward(H_OnClientResult);
	Call_PushCell(pUser);
	Call_PushCell(result);
	Call_PushCell(fromCache);
	Call_Finish();
}

Action Call_ProxyKiller_DoClientResultCache(ProxyUser pUser, bool result)
{
	Action retval = Plugin_Continue;
	Call_StartForward(H_DoClientResultCache);
	Call_PushCell(pUser);
	Call_PushCell(result);
	Call_Finish(retval);
	return retval;
}

void Call_ProxyKiller_OnClientResultCache(ProxyUser pUser, bool result)
{
	Call_StartForward(H_OnClientResultCache);
	Call_PushCell(pUser);
	Call_PushCell(result);
	Call_Finish();
}

Action Call_ProxyKiller_DoClientPunishment(ProxyUser pUser, bool fromCache)
{
	Action retval = Plugin_Continue;
	Call_StartForward(H_DoClientPunishment);
	Call_PushCell(pUser);
	Call_PushCell(fromCache);
	Call_Finish(retval);
	return retval;
}

void Call_ProxyKiller_OnClientPunishment(ProxyUser pUser, bool fromCache)
{
	Call_StartForward(H_OnClientPunishment);
	Call_PushCell(pUser);
	Call_PushCell(fromCache);
	Call_Finish();
}

// =========================================================== //
