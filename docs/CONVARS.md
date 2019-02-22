# ProxyKiller Convars

---

**After running the plugin for the first time, you'll find an auto-generated config for the convars at `/csgo/cfg/sourcemod/ProxyKiller.cfg`**

---

### ProxyKiller_Enable
* Default value of "**1**"
* Value of "**0**" will disable ProxyKiller
* Value of "**1**" will enable ProxyKiller

---

### ProxyKiller_KickMessage
* Default value of "**Kicked due to proxy usage!**"
* Message sent to clients whenever they're kicked for proxy usage

---

### ProxyKiller_LogSteamId
* Default value of "**0**"
* Value of "**0**" will disable this feature
* Value of "**1**" will enable logging steamids when a client is punished

---

### ProxyKiller_CacheLifetime
* Default value of "**43200**"
* Time in second(s) when to invalidate cache entries
* It is recommended that you set this to at least 1 hour (3600 seconds)

---

### ProxyKiller_IgnoreAppOwners
* Default value of "**[624820](https://steamdb.info/app/624820/)**"
* Leave empty to disable this feature
* Ignore owners of these appids when checking for proxies
* Checking will occur if a client does not have ANY of these
* Separate each appid by a comma ex: \"12345, 4444, 624820\"

---