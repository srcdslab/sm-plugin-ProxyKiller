// =========================================================== //

#define MAX_RAWBODY_TYPE_LENGTH 64
#define MAX_RAWBODY_VALUE_LENGTH 2048

// =========================================================== //

bool SetRawBody(Handle request, ProxyHTTP http)
{
	if (!http.HasRawBody)
	{
		return false;
	}

	char bodyValue[MAX_RAWBODY_VALUE_LENGTH];
	http.GetRawBody(bodyValue, sizeof(bodyValue));

	char bodyType[MAX_RAWBODY_TYPE_LENGTH];
	http.GetRawBodyType(bodyType, sizeof(bodyType));

	return SteamWorks_SetHTTPRequestRawPostBody(request, bodyType, bodyValue, strlen(bodyValue));
}

// =========================================================== //