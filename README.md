# ProxyKiller
#### Plugin designed to literally kill proxy users!

This plugin will take care of your server's proxy users and kick them

---

See [CONFIG.md](https://bitbucket.org/Sikarii/proxykiller/src/master/docs/CONFIG.md) for documentation of the config

See [CONVARS.md](https://bitbucket.org/Sikarii/proxykiller/src/master/docs/CONVARS.md) for documentation of the convars

---

## **Installation**

* Download [ProxyKiller-latest.smx](https://bitbucket.org/Sikarii/proxykiller/downloads/ProxyKiller-latest.smx) and drop it to `/csgo/addons/sourcemod/plugins/`

* Edit or use the [example configuration](https://bitbucket.org/Sikarii/proxykiller/src/master/docs/CONFIG.md) and drop it to `/csgo/cfg/sourcemod/ProxyKiller-Config.cfg`

* Add an entry called "ProxyKiller" to `/csgo/addons/sourcemod/configs/databases.cfg`

---

## **Known Limitations**
* Requests limited to GET method
* Caching layer limited to MySQL only
* Response parsing limited only to JSON
* Cache manipulation not possible via ingame commands
---