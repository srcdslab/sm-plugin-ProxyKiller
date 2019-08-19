// =========================================================== //

#define MAX_MIGRATION_LENGTH 128

enum MigrationResult
{
	Result_LookupFailure = 0,
	Result_ProviderMismatch,
	Result_NoInitialError,
	Result_OtherFailure
};

// =========================================================== //

#include "ProxyKiller/migrations/cache_mysql_1_1_0_to_2_0_0.sp"

// =========================================================== //

MigrationResult ApplyMigration(char migration[MAX_MIGRATION_LENGTH])
{
	char migrationFuncName[sizeof(migration) + 12] = "PKMigration_";
	StrCat(migrationFuncName, sizeof(migrationFuncName), migration);

	Function migrationFunc = GetFunctionByName(null, migrationFuncName);
	if (migrationFunc == INVALID_FUNCTION)
	{
		return Result_LookupFailure;
	}

	MigrationResult result = Result_NoInitialError;
	Call_StartFunction(null, migrationFunc);
	Call_Finish(result);
	return result;
}

public void OnSQL_MigrationSuccess(Database db, any data, int numQueries, DBResultSet[] results, any[] queryData)
{
	g_Logger.InfoMessage("Successfully executed migration");
}

public void OnSQL_MigrationFailure(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	g_Logger.ErrorMessage("Failure during migration, one or more queries failed!");
}

// =========================================================== //