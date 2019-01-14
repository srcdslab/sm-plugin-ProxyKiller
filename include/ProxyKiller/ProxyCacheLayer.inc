// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyCacheLayer_included_
#endinput
#endif
#define _ProxyCacheLayer_included_

// =========================================================== //

static char INSERT_RECORD[] =
"INSERT INTO `ProxyKiller_Cache` (`ip`,`should_block`, `timestamp`) "
..."VALUES ('%s', '%d', CURRENT_TIMESTAMP) "
..."ON DUPLICATE KEY UPDATE "
..."`timestamp` = VALUES(`timestamp`), "
..."`should_block` = IF(`should_block` = 0, VALUES(`should_block`), 1);";

static char SELECT_RECORD[] =
"SELECT `should_block`, "
..."UNIX_TIMESTAMP(`timestamp`) "
..."FROM `ProxyKiller_Cache` "
..."WHERE `ip` = '%s';";

// =========================================================== //

methodmap ProxyCacheLayer < ProxyDatabase
{
	public ProxyCacheLayer(ProxyDatabase db)
	{
		return view_as<ProxyCacheLayer>(db);
	}
	
	public void AddEntry(char[] ip, bool shouldBlock, SQLQueryCallback callback)
	{
		char query[512];
		Format(query, sizeof(query), INSERT_RECORD, ip, shouldBlock);
		this.Query(OnEntry, query);
	}
	
	public void TryGetCache(char[] ip, SQLQueryCallback callback, any data)
	{
		char query[512];
		Format(query, sizeof(query), SELECT_RECORD, ip);
		this.Query(callback, query, data);
	}
}

// =========================================================== //