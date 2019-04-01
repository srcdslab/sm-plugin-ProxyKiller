// =========================================================== //

bool HandleResponse(const char[] response, ProxyContext ctx)
{
	char expectValue[MAX_RESPONSE_VALUE_LENGTH];
	ctx.Service.Response.GetValue(expectValue, sizeof(expectValue));
	
	char responseValue[MAX_RESPONSE_VALUE_LENGTH];
	TokenizeAll(ctx.User, expectValue, sizeof(expectValue));
	
	switch (ctx.Service.Response.Type)
	{
		case RT_JSON: Internal_Handle_JSON(response, ctx, responseValue, sizeof(responseValue));
		case RT_PLAINTEXT: Internal_Handle_PlainText(response, responseValue, sizeof(responseValue));
		case RT_STATUSCODE: Internal_Handle_StatusCode(response, responseValue, sizeof(responseValue));
	}
	
	if (ctx.Service.Response.Compare == RC_EQUAL)
	{
		return StrEqual(responseValue, expectValue);
	}
	else
	{
		return !StrEqual(responseValue, expectValue);
	}
}

// =========================================================== //

static void Internal_Handle_JSON(const char[] response, ProxyContext ctx, char[] buffer, int maxlength)
{
	char obj[MAX_RESPONSE_NAME_LENGTH];
	ctx.Service.Response.GetObject(obj, sizeof(obj));
	
	char objs[16][MAX_RESPONSE_NAME_LENGTH];
	int objCount = ExplodeString(obj, ".", objs, sizeof(objs), sizeof(objs[]));
	
	char responseValue[MAX_RESPONSE_VALUE_LENGTH];
	JSON_Object currentObj = json_decode(response);
	JSON_Object originalPtr = currentObj;
	
	for (int i = 0; i < objCount; i++)
	{
		TokenizeAll(ctx.User, objs[i], sizeof(objs[]));
		
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
				currentObj.GetString(objs[i], responseValue, sizeof(responseValue));
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
	strcopy(buffer, maxlength, response);
}

static void Internal_Handle_StatusCode(const char[] response, char[] buffer, int maxlength)
{
	strcopy(buffer, maxlength, response);
}

// =========================================================== //