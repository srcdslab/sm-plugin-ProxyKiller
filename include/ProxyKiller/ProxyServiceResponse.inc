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
	RT_JSON = 0,	/**< Parse as JSON */
	RT_PLAINTEXT,	/**< Parse as Plaintext */
	RT_STATUSCODE,	/**< Parse http status code */
	RT_COUNT
};

/**
 * Types of response equality checks
 */
enum ResponseCompare
{
	RC_EQUAL = 0,	/**< Look for equality */
	RC_NOTEQUAL,	/**< Look for inequality */
	RC_COUNT
};

char TypePhrases[RT_COUNT][] =
{
	"json",
	"plaintext",
	"statuscode"
};

// =========================================================== //

methodmap ProxyServiceResponse < StringMapEx
{
	public ProxyServiceResponse()
	{
		return view_as<ProxyServiceResponse>(new StringMapEx());
	}
	
	public void SetType(char[] type)
	{
		for (int i = 0; i < sizeof(TypePhrases); i++)
		{
			if (StrEqual(TypePhrases[i], type))
			{
				this.SetValue("type", i);
			}
		}
	}
	
	property ResponseType Type
	{
		public get() { return view_as<ResponseType>(this.GetInt("type")); }
	}
	
	property ResponseCompare Compare
	{
		public get() { return view_as<ResponseCompare>(this.GetInt("compare")); }
		public set(ResponseCompare compare) { this.SetValue("compare", compare); }
	}

	public void GetObject(char[] buffer, int maxlength)
	{
		if (this.Type == RT_JSON)
		{
			this.GetString("object", buffer, maxlength);
		}
	}

	public void SetObject(char[] objectStr)
	{
		if (this.Type == RT_JSON)
		{
			this.SetString("object", objectStr);
		}
	}

	public void GetValue(char[] buffer, int maxlength)
	{
		this.GetString("value", buffer, maxlength);
	}

	public void SetValue(char[] valueStr)
	{
		this.SetString("value", valueStr);
	}
}

// =========================================================== //