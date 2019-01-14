# ProxyKiller Config

--- 

**ProxyKiller config must start with the `ProxyKiller` section**

**Config should be located at `/csgo/cfg/sourcemod/ProxyKiller-Config.cfg`**

---

Use of `{client_ip}` will replace the string with the client's ip address

It is possible to traverse objects AND arrays in the token (See example below)

--- 

## Possible keys to use:
* `url` - This is the base url of the service
* `token` - This is the name of the token to look for
* `tokenValue` - This is the value of the token to look for
* `params` - Parameters to use on the request - if needed

---

## Example configuration:
```
"ProxyKiller"
{
	"proxycheck.io"
	{
		"url"		"http://proxycheck.io/v2/{client_ip}"
		"token"		"{client_ip}.proxy"
		"tokenvalue"	"yes"
		"params"
		{
			"vpn"	"1"
			"tag"   "My server"
		}
	}
}
```