// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyHTTPResponse_included_
#endinput
#endif
#define _ProxyHTTPResponse_included_

// =========================================================== //

methodmap ProxyHTTPResponse < StringMapEx
{
	public ProxyHTTPResponse(bool failure, int status)
	{
		StringMapEx response = new StringMapEx();
		response.SetValue("status", status);
		response.SetValue("failure", failure);
		return view_as<ProxyHTTPResponse>(response);
	}

	property int Status
	{
		public get() { return this.GetInt("status"); }
	}

	property bool Failure
	{
		public get() { return this.GetBool("failure"); }
	}
}

// =========================================================== //