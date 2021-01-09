# TeslaMate Addon for Home Assistant

This addon builds on the excellent work of [Adrian Kumpf](https://github.com/adriankumpf/teslamate). See his repo for information regarding the TeslaMate application.

This addon is part of [my Home Assistant addon repo](https://github.com/matt-FFFFFF/hassio-addon-repository) - see link for instructions on how to add to Home Assistant.

## Installation

1. Add [my repository](https://github.com/matt-FFFFFF/hassio-addon-repository) to Home Assistant. See [installing third party addons](https://www.home-assistant.io/hassio/installing_third_party_addons/) from teh Home Assistant documentation.
2. Add the `TeslaMate` and the `PostgreSQL` addons from my repo and the `Grafana` addon from the community repo.
3. Before starting Postgres, [configure](https://github.com/matt-FFFFFF/hassio-addon-postgres/blob/main/README.md) the addon by setting the DB name, username and password. Now you can start it up.

### DB Connection

If using the Postgres addon from my addon repo, the database host is `29b65938-postgres`. Below is a snippit from the TeslaMate addon configuration, just replace the DB name, username and password and you will be good to go.

```yaml
database_user: mydbuser
database_pass: mydbpass
database_name: mydbname
database_host: 29b65938-postgres
database_ssl: false
database_port: 5432
```

### MQTT Configuration

You **must** have a username and password defined for your MQTT user, do not use the HA local login (thanks [quach128](https://github.com/quach128)). Below is a sample configuration using the Mosquitto MQTT addon agailable in the Home Assistant core addon repo:

```yaml
mqtt_host: core-mosquitto
mqtt_user: mymqttuser
mqtt_pass: mymqtttpass
mqtt_tls: false
mqtt_tls_accept_invalid_certs: true
```

#### Mosquitto access control list

You must specify an access control list entry for the t3eslamate user, for example:

```text
user teslamate
topic readwrite teslamate/#
```

See the [official docs](https://github.com/home-assistant/addons/blob/master/mosquitto/DOCS.md) on how to configure access control with Mosquitto

### Grafana Configuration

I recommend you use the existing Grafana addon from the community addons

#### Data Source

Configure a PostgreSQL data source as follows:

![Grafana Postgres data source](https://raw.githubusercontent.com/matt-FFFFFF/hassio-addon-teslamate/main/media/grafana-postgres.png)

#### Automatically Uploading Grafana Dashboards

Without this step you won't be able to use the TeslaMate dashboards, so this is recommended.

Configure the `Grafana` addon and set the admin username and password - we will need this to upload the dashboards:

```yaml
env_vars:
  - name: GF_SECURITY_ADMIN_USER
    value: admin
  - name: GF_SECURITY_ADMIN_PASSWORD
    value: mysecretpassword
```

Now configure the `Teslamate` addon:

```yaml
grafana_import_dashboards: true
grafana_folder_name: TeslaMate
grafana_host: a0d7b954-grafana   # this is correct if you use the community addon
grafana_port: 3000               # this is correct if you use the community addon
grafana_user: admin
grafana_pass: pass
```
