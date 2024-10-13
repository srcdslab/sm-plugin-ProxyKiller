// =========================================================== //

#define MAX_RESPONSE_TYPE_LENGTH 32
#define MAX_RESPONSE_COMPARE_LENGTH 16

// =========================================================== //

bool GetResultFromResponse(const char[] response, ProxyServiceContext ctx)
{
	g_Logger.PrintFrame();

	char expectValue[MAX_RESPONSE_VALUE_LENGTH];
	ctx.Service.ExpectedResponse.GetValue(expectValue, sizeof(expectValue));

	ExpandRuntimeVariables(ctx.User, expectValue, sizeof(expectValue));

	char responseValue[MAX_RESPONSE_VALUE_LENGTH];
	switch (ctx.Service.ExpectedResponse.Type)
	{
		case ResponseType_JSON:
		{
			Internal_Handle_JSON(response, ctx, responseValue, sizeof(responseValue));
		}
		case ResponseType_PLAINTEXT:
		{
			Internal_Handle_PlainText(response, responseValue, sizeof(responseValue));
		}
		case ResponseType_STATUSCODE:
		{
			Internal_Handle_StatusCode(ctx, responseValue, sizeof(responseValue));
		}
	}

	if (ctx.Service.ExpectedResponse.Compare == ResponseCompare_EQUAL)
	{
		return StrEqual(responseValue, expectValue, false);
	}
	else
	{
		return !StrEqual(responseValue, expectValue, false);
	}
}

// =========================================================== //

static void Internal_Handle_JSON(const char[] response, ProxyServiceContext ctx, char[] buffer, int maxlength)
{
	g_Logger.PrintFrame();

	char obj[MAX_RESPONSE_NAME_LENGTH];
	ctx.Service.ExpectedResponse.GetObject(obj, sizeof(obj));

	char objs[16][MAX_RESPONSE_NAME_LENGTH];
	int objCount = ExplodeString(obj, ".", objs, sizeof(objs), sizeof(objs[]));

	char responseValue[MAX_RESPONSE_VALUE_LENGTH];
	JSON_Object currentObj = json_decode(response);
	JSON_Object originalPtr = currentObj;

	for (int i = 0; i < objCount; i++)
	{
		ExpandRuntimeVariables(ctx.User, objs[i], sizeof(objs[]));

		if (i < objCount - 1)
		{
			int arrayStart = FindCharInString(objs[i], '[', true);
			int arrayEnding = FindCharInString(objs[i], ']', true);

			if (arrayEnding > arrayStart + 1)
			{
				int maxlen = arrayEnding - arrayStart;
				char[] indexString = new char[maxlen];

				char[] objArrayless = new char[arrayStart + 1];
				Format(objArrayless, arrayStart + 1, "%s", objs[i]);
				Format(indexString, maxlen, "%s", objs[i][arrayStart + 1]);

				currentObj = GetObjectSafe(currentObj, objArrayless);
				currentObj = GetObjectSafe(currentObj, _, StringToInt(indexString));
			}
			else
			{
				currentObj = GetObjectSafe(currentObj, objs[i]);
			}
		}
		else
		{
			if (currentObj != null)
			{
				switch (currentObj.GetType(objs[i]))
				{
					case JSON_Type_String:
					{
						currentObj.GetString(objs[i], responseValue, sizeof(responseValue));
					}
					case JSON_Type_Int:
					{
						int val = currentObj.GetInt(objs[i]);
						IntToString(val, responseValue, sizeof(responseValue));
					}
					case JSON_Type_Float:
					{
						float val = currentObj.GetFloat(objs[i]);
						FloatToString(val, responseValue, sizeof(responseValue));
					}
					case JSON_Type_Bool:
					{
						int val = currentObj.GetBool(objs[i]) ? 1 : 0;
						IntToString(val, responseValue, sizeof(responseValue));
					}
					default:
					{
						g_Logger.DebugMessage("Invalid key type for %s (%s)", objs[i], obj);
					}
				}
			}
		}
	}

	if (originalPtr != null)
	{
		originalPtr.Cleanup();
		delete originalPtr;
	}

	strcopy(buffer, maxlength, responseValue);
}

static void Internal_Handle_PlainText(const char[] response, char[] buffer, int maxlength)
{
	g_Logger.PrintFrame();
	strcopy(buffer, maxlength, response);
}

static void Internal_Handle_StatusCode(ProxyServiceContext ctx, char[] buffer, int maxlength)
{
	g_Logger.PrintFrame();

	char statusCode[12];
	IntToString(ctx.Service.Response.Status, statusCode, sizeof(statusCode));

	strcopy(buffer, maxlength, statusCode);
}

// =========================================================== //