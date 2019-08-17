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

public int PKMigration_cache_mysql_1_1_0_to_2_0_0()
{
	int failureCount = 0;
	for (int i = 0; i < sizeof(Queries); i++)
	{
		if (!SQL_FastQuery(g_Cache.Provider, Queries[i]))
		{
			char error[256];
			SQL_GetError(g_Cache.Provider, error, sizeof(error));

			failureCount++;
			g_Logger.ErrorMessage("Failed to apply migration query - Error: \"%s\"", error);
		}
	}

	return failureCount;
}

// =========================================================== //