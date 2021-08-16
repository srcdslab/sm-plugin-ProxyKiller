// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyServiceResponse_included_
#endinput
#endif
#define _ProxyServiceResponse_included_

// =========================================================== //

/**
 * Types of supported responses
 */
enum ResponseType
{
	ResponseType_JSON = 0,	 /**< Parse as JSON */
	ResponseType_PLAINTEXT,	 /**< Parse as Plaintext */
	ResponseType_STATUSCODE, /**< Parse http status code */
	ResponseType_COUNT
};

/**
 * Types of response equality checks
 */
enum ResponseCompare
{
	ResponseCompare_EQUAL = 0,	/**< Look for equality */
	ResponseCompare_NOTEQUAL,	/**< Look for inequality */
	ResponseCompare_COUNT
};

// =========================================================== //

methodmap ProxyServiceResponse < StringMapEx
{
	public ProxyServiceResponse(ResponseType type, ResponseCompare compare, char[] value, char[] objStr = "")
	{
		StringMapEx response = new StringMapEx();
		response.SetValue("type", type);
		response.SetValue("compare", compare);
		response.SetString("value", value);
		response.SetString("object", objStr);
		return view_as<ProxyServiceResponse>(response);
	}

	property ResponseType Type
	{
		public get() { return view_as<ResponseType>(this.GetInt("type")); }
	}

	property ResponseCompare Compare
	{
		public get() { return view_as<ResponseCompare>(this.GetInt("compare")); }
	}

	public void GetValue(char[] buffer, int maxlength)
	{
		this.GetString("value", buffer, maxlength);
	}

	public void GetObject(char[] buffer, int maxlength)
	{
		this.GetString("object", buffer, maxlength);
	}
}

// =========================================================== //