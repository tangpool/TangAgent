**v0.1.4**

* implement stratum method: `client.reconnect`, `client.get_version`, `client.show_message`
* add config options: `stratum.server.wan.host`, `stratum.server.wan.port`

**v0.1.3.2**

* write stats data to temp file and than rename file name

**v0.1.3**

* add limit tcp connections
* add agent id expired time
* old versions are not support anymore

**v0.1.2**

* fixed counter for session add number

**v0.1.1**

* support multi tcp connections
* change agent.id format from Hexadecimal to Decimal
* write/flush sessions stats to disk every interval seconds or before server shutdown
* check last pool use time before try to switch pools
* disable drop tcp connection
* increase submit nonce limited rate

**v0.1.0**

* first stable release
