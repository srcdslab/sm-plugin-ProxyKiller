// =========================================================== //

void CreateCommands()
{
	RegAdminCmd("sm_proxykiller_rules_add", Command_RulesAdd, ADMFLAG_RCON, "Adds an expression to ProxyKiller Rules");
	RegAdminCmd("sm_proxykiller_rules_delete", Command_RulesDelete, ADMFLAG_RCON, "Deletes an expression from ProxyKiller Rules");
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

	TryDeleteRule(expression);
	return Plugin_Handled;
}

// =========================================================== //