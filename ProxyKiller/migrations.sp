// =========================================================== //

#define MAX_MIGRATION_LENGTH 128

enum MigrationResult
{
	Result_Success = 0,
	Result_LookupFailure,
	Result_ProviderMismatch,
	Result_FailedQueries,
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

	MigrationResult result = Result_Success;
	Call_StartFunction(null, migrationFunc);
	Call_Finish(result);
	return result;
}

// =========================================================== //