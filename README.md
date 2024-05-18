# ProxyKiller
#### Plugin designed to literally kill proxy users!  
Please see the [Wiki](https://bitbucket.org/Sikarii/proxykiller/wiki) for a featured documentation of the plugin.

## **Features**
- **Extensive logging**
	 - Decide what logging messages you want to see and where
- **Extensive plugin api**
	 - Tons of natives and forwards available for third-party plugins
 - **Admin flags & app owners whitelisting**
	 - Configure clients with admin flags to be ignored
	 - Configure clients with steam apps to be ignored
 - **Configurable caching**
	 - Configurable caching mode
	 - Configurable caching lifetime
	 - None/MySQL/SQLite providers available
 - **Configurable rules**
	 - 	Supports adding and removing rules in-game
	 - Could be expanded to more complex rules in the future
	 -  NOTE: **Currently (2.0.0) rules only support whitelisting**
- **Configurable punishments**
	- Choose from log, kick or ban (ban length also configurable)
	- Configurable logging message (also supports [variables](https://bitbucket.org/Sikarii/proxykiller/wiki/Variables))
	- Configurable punishment message (also supports [variables](https://bitbucket.org/Sikarii/proxykiller/wiki/Variables))
- **Entirely configurable service**
	- Supports config and runtime [variables](https://bitbucket.org/Sikarii/proxykiller/wiki/Variables)!
	- Choose from status code, plaintext or json response
	- Choose from inequality or equality comparisations
	- Choose what response value is considered as a Proxy/VPN
	- GET, HEAD, POST, PUT, DELETE, OPTIONS, PATCH request methods supported
- **Whitelist & Blacklist (SteamID only)**
	- Whitelist: to don't perform check on your whitelisted users
	- Blacklist: to always perform a check on your blacklisted users

	*Note: If users are on both the Whitelist and Blacklist, the Blacklist will always be the final outcome.*

## **Requirements**
- [SteamWorks](https://forums.alliedmods.net/showthread.php?t=229556)

## **Installation**

 1. Make sure the above requiremens are met
 2. Compile the plugin and drop it to `/addons/sourcemod/plugins/`
 3. Configure ProxyKiller service [(example configs)](https://bitbucket.org/Sikarii/proxykiller/wiki/Config%20Examples) into `/cfg/sourcemod/ProxyKiller-Config.cfg`
 4. **Optional but recommended** - Depending on your configuration, add an "**ProxyKiller**" entry    
 to `/addons/sourcemod/configs/databases.cfg`, the driver can be either "sqlite" or "mysql"

## **Discord Support**
For discord support : [Proxy Killer Discord repository](https://github.com/srcdslab/sm-plugin-ProxyKiller-Discord)