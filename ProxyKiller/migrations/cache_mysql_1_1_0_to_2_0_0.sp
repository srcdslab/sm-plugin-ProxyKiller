// =========================================================== //

static char Queries[][] =
{
	"ALTER TABLE `%s_Cache` CHANGE `ip` `IPAddress` VARCHAR(24)",
	"ALTER TABLE `%s_Cache` CHANGE `timestamp` `Timestamp` TIMESTAMP",
	"ALTER TABLE `%s_Cache` CHANGE `should_block` `Result` TINYINT(1) NOT NULL",
	"ALTER TABLE `%s_Cache` ADD COLUMN `ServiceName` VARCHAR(128) NOT NULL AFTER `IPAddress`",
	"ALTER TABLE `%s_Cache` DROP PRIMARY KEY, ADD PRIMARY KEY(`IPAddress`, `ServiceName`)",
};

// =========================================================== //

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
	if (!ProxyKiller_Cache_IsInit())
	{
		return Result_OtherFailure;
	}

	if (g_Cache.Mode != CacheMode_MySQL)
	{
		return Result_ProviderMismatch;
	}

	Transaction txn = new Transaction();
	ArrayList queries = new ArrayList(ByteCountToCells(512));

	char prefix[64];
	gCV_DatabaseTablePrefix.GetString(prefix, sizeof(prefix));

	Database provider = g_Cache.Provider;

	for (int i = 0; i < sizeof(Queries); i++)
	{
		char query[256];
		provider.Format(query, sizeof(query), Queries[i], prefix);
		
		txn.AddQuery(query);
		queries.PushString(query);
	}

	char serviceName[MAX_SERVICE_NAME_LENGTH];
	g_Config.Service.GetName(serviceName, sizeof(serviceName));

	char query[80 + sizeof(serviceName) + sizeof(prefix)];
	Format(query, sizeof(query), "UPDATE `%s_Cache` SET `ServiceName` = '%s' WHERE `ServiceName` = ''", prefix, serviceName);

	txn.AddQuery(query);
	queries.PushString(query);

	provider.Execute(txn, OnSQL_MigrationSuccess, OnSQL_MigrationFailure, queries, DBPrio_High);
	return Result_NoInitialError;
}

// =========================================================== //