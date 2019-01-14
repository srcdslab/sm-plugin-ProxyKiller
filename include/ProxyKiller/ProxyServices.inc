// ================== DOUBLE INCLUDE ========================= //

#if defined _ProxyServices_included_
#endinput
#endif
#define _ProxyServices_included_

// =========================================================== //

methodmap ProxyServices < ArrayList
{
	public ProxyServices()
	{
		return view_as<ProxyServices>(new ArrayList());
	}
	
	public void AddService(ProxyService service)
	{
		this.Push(service);
	}
}

// =========================================================== //