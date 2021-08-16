// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyRules_included_
#endinput
#endif
#define _ProxyRules_included_

// =========================================================== //

/**
 * Types of rules providers available
 */
enum ProxyRulesMode
{
	RulesMode_Inherit = -1,	/**< Inherit mode from ProxyCache */
	RulesMode_None,			/**< No whitelist */
	RulesMode_MySQL,		/**< Use MySQL */
	RulesMode_SQLite,		/**< Use SQLite */
	RulesMode_COUNT
};

/**
 * Types of proxy rules available
 */
enum ProxyRulesType
{
	RulesType_None = 0,		/**< No rule set */
	RulesType_Whitelist,	/**< Whitelist rule */
	RulesType_COUNT
};

// =========================================================== //

methodmap ProxyRules < StringMapEx
{
	public ProxyRules(ProxyRulesMode mode, any provider = 0)
	{
		StringMapEx rulesObj = new StringMapEx();
		rulesObj.SetValue("mode", mode);
		rulesObj.SetValue("provider", provider);
		return view_as<ProxyRules>(rulesObj);
	}

	property ProxyRulesMode Mode
	{
		public get() { return this.GetAny("mode"); }
	}

	property any Provider
	{
		public get() { return this.GetAny("provider"); }
	}
}

// =========================================================== //