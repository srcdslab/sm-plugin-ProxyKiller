// =========================================================== //

void CreateCommands()
{
	RegAdminCmd("sm_proxykiller_rules_add", Command_RulesAdd, ADMFLAG_RCON, "Adds an expression to ProxyKiller Rules");
	RegAdminCmd("sm_proxykiller_rules_delete", Command_RulesDelete, ADMFLAG_RCON, "Deletes an expression from ProxyKiller Rules");

	RegAdminCmd("sm_proxykiller_apply_migration", Command_ApplyMigration, ADMFLAG_RCON, "Applies a migration to ProxyKiller");

	RegAdminCmd("sm_proxykiller_reload_whitelist", Command_ReloadWhitelist, ADMFLAG_RCON, "Reloads the whitelist");
	RegAdminCmd("sm_proxykiller_reload_blacklist", Command_ReloadBlacklist, ADMFLAG_RCON, "Reloads the blacklist");
}

// =========================================================== //

public Action Command_RulesAdd(int client, int args)
{
	if (args <= 0)
	{
		ReplyToCommand(client, "Usage: sm_proxykiller_rules_add <expression>");
		return Plugin_Handled;
	}

	char expression[32];
	GetCmdArgString(expression, sizeof(expression));

	TrimString(expression);
	StripQuotes(expression);

	TryPushRule(expression);
	return Plugin_Handled;
}

public Action Command_RulesDelete(int client, int args)
{
	if (args <= 0)
	{
		ReplyToCommand(client, "Usage: sm_proxykiller_rules_delete <expression>");
		return Plugin_Handled;
	}

	char expression[32];
	GetCmdArgString(expression, sizeof(expression));

	TrimString(expression);
	StripQuotes(expression);

	TryDeleteRule(expression);
	return Plugin_Handled;
}


public Action Command_ApplyMigration(int client, int args)
{
	if (args <= 0)
	{
		return Plugin_Handled;
	}

	char migration[MAX_MIGRATION_LENGTH];
	GetCmdArg(1, migration, sizeof(migration));
	MigrationResult result = ApplyMigration(migration);

	switch (result)
	{
		case Result_LookupFailure:
		{
			g_Logger.ErrorMessage("Failed to lookup migration by name \"%s\"", migration);
			ReplyToCommand(client, "Failed to lookup migration by name \"%s\"", migration);
		}
		case Result_ProviderMismatch:
		{
			g_Logger.ErrorMessage("Failed to apply migration \"%s\" as providers mismatch", migration);
			ReplyToCommand(client, "Failed to apply migration \"%s\" as providers mismatch", migration);
		}
	}

	return Plugin_Handled;
}

public Action Command_ReloadWhitelist(int client, int args)
{
	LoadWhitelist();
	ReplyToCommand(client, "Whitelist cache refreshed", client);
	LogAction(client, -1, "[ProxyKiller] \"%L\" has refreshed Whitelist cache.", client);
	return Plugin_Handled;
}

public Action Command_ReloadBlacklist(int client, int args)
{
	LoadBlacklist();
	ReplyToCommand(client, "Blacklist cache refreshed", client);
	LogAction(client, -1, "[ProxyKiller] \"%L\" has refreshed Blacklist cache.", client);
	return Plugin_Handled;
}

// =========================================================== //