// ================== DOUBLE INCLUDE ========================= //

#if defined _StringMapEx_included_
#endinput
#endif
#define _StringMapEx_included_

// =========================================================== //

methodmap StringMapEx < StringMap 
{
	public StringMapEx()
	{
		return view_as<StringMapEx>(new StringMap());
	}
	
	public any GetAny(char[] key)
	{
		any value;
		this.GetValue(key, value);
		return value;
	}
	
	public int GetInt(char[] key)
	{
		int value;
		this.GetValue(key, value);
		return value;
	}
	
	public bool GetBool(char[] key)
	{
		bool value;
		this.GetValue(key, value);
		return value;
	}
	
	public float GetFloat(char[] key)
	{
		float value;
		this.GetValue(key, value);
		return value;
	}
	
	public bool HasKeyWithString(char[] key)
	{
		char dummy[1];
		return this.GetString(key, dummy, sizeof(dummy));
	}
}

// =========================================================== //