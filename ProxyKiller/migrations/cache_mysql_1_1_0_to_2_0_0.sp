// =========================================================== //

static char Queries[][] =
{
	"ALTER TABLE ProxyKiller_Cache CHANGE `ip` `IPAddress` VARCHAR(24)",
	"ALTER TABLE ProxyKiller_Cache CHANGE `timestamp` `Timestamp` TIMESTAMP",
	"ALTER TABLE ProxyKiller_Cache CHANGE `should_block` `Result` TINYINT(1) NOT NULL",
	"ALTER TABLE ProxyKiller_Cache ADD COLUMN `ServiceName` VARCHAR(128) NOT NULL AFTER `IPAddress`",
	"ALTER TABLE ProxyKiller_Cache DROP PRIMARY KEY, ADD PRIMARY KEY(`IPAddress`, `ServiceName`)",
};

// =========================================================== //

// EXPLANATION:
/*
	- Rename ProxyKiller_Cache `ip` to `IPAddress`
	- Rename ProxyKiller_Cache `timestamp` to `Timestamp`
	- Rename ProxyKiller_Cache `should_block` to `Result`
	- Add a new column "ServiceName" VARCHAR(128) after `IPAddress`
	- Drop `IPAddress` (old `ip`) as primary key
	- Add (`IPAddress` + `ServiceName`) as primary key
*/

// =========================================================== //

public MigrationResult PKMigration_cache_mysql_1_1_0_to_2_0_0()
{
	if (!ProxyKiller_IsCacheInit())
	{
		return Result_OtherFailure;
	}

	if (g_Cache.Mode != CacheMode_MySQL)
	{
		return Result_ProviderMismatch;
	}
	
	Transaction txn = new Transaction();
	ArrayList queries = new ArrayList(ByteCountToCells(512));

	for (int i = 0; i < sizeof(Queries); i++)
	{
		txn.AddQuery(Queries[i]);
		queries.PushString(Queries[i]);
	}

	char serviceName[MAX_SERVICE_NAME_LENGTH];
	g_Config.Service.GetName(serviceName, sizeof(serviceName));
	
	char query[80 + sizeof(serviceName)];
	Format(query, sizeof(query), "UPDATE `ProxyKiller_Cache` SET `ServiceName` = '%s' WHERE `ServiceName` = ''", serviceName);

	txn.AddQuery(query);
	queries.PushString(query);

	SQL_ExecuteTransaction(g_Cache.Provider, txn, OnSQL_MigrationSuccess, OnSQL_MigrationFailure, queries);
	return Result_NoInitialError;
}

// =========================================================== //