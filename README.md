
# ProxyKiller
#### Plugin designed to literally kill proxy users!  
Please see the [Wiki](https://bitbucket.org/Sikarii/proxykiller/wiki) for a featured documentation of the plugin.

---

## **Features**
- Extensive logging
	 - Decide what logging messages you want to see and where
- Extensive plugin api
	 - Tons of natives and forwards available for third-party plugins
- Caching of IP Addresses
  	 - Configurable caching time
 - Admin flags & app owners whitelisting
	 - Configure clients with admin flags to be ignored
	 - Configure clients with steam apps to be ignored
 - Configurable rules
	 - 	Supports adding and removing rules in-game
	 - Could be expanded to more complex rules in the future
	 -  NOTE: **Currently (2.0.0) rules only support whitelisting**
- Configurable punishments
	- Choose from log, kick or ban (ban length also configurable)
	- Configurable kick message (also supports variables)
	- Configurable logging message (also supports variables)
- Entirely configurable service
	- Supports config and runtime variables! (See **X**)
	- Choose from status code, plaintext or json response
	- Choose from inequality or equality comparisations
	- Choose what response value is considered as a Proxy/VPN
	- GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH request methods supported

---

## **Requirements**
- [SteamWorks](https://forums.alliedmods.net/showthread.php?t=229556)

---


## **Installation**
- **Make sure the above requirements are met**
- Download [ProxyKiller-latest.smx](https://bitbucket.org/Sikarii/proxykiller/downloads/ProxyKiller-latest.smx) and drop it to `/csgo/addons/sourcemod/plugins/`
- Edit or use the [example configuration](https://bitbucket.org/Sikarii/proxykiller/src/master/docs/CONFIG.md) and drop it to `/csgo/cfg/sourcemod/ProxyKiller-Config.cfg`
- Add an entry called "ProxyKiller" to `/csgo/addons/sourcemod/configs/databases.cfg`

---

## **Known Limitations**
- Caching/rules layer limited to MySQL only (No implementation for other providers yet)

---