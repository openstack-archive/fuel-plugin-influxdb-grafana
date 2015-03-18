InfluxDB-Grafana Plugin for Fuel
================================

InfluxDB-Grafana plugin
-----------------------

Overview
--------

[InfluxDB](http://influxdb.com/) provides an open source time series database.
[Grafana](http://grafana.org/) is a rich dashboard that allows to manipulate graph for InfluxDB.

Requirements
------------

| Requirement                      | Version/Comment |
|----------------------------------|-----------------|
| Mirantis OpenStack compatibility | 6.1 or higher   |
| Fuel Plugin Builder              | 2.0.0           |

Recommendations
---------------

None.

Limitations
-----------

None.

Installation Guide
==================

**InfluxDB-Grafana** plugin installation
----------------------------------------


To install the InfluxDB-Grafana plugin, follow these steps:

1. Download the plugin from the [Fuel Plugins
   Catalog](https://software.mirantis.com/download-mirantis-openstack-fuel-plug-ins/).

2. Copy the plugin file to the Fuel Master node. Follow the [Quick start
   guide](https://software.mirantis.com/quick-start/) if you don't have a running
   Fuel Master node yet.

   ```
   scp influxdb_grafana-6.1-6.1.0-0.noarch.rpm root@<the Fuel Master node IP address>:
   ```

3. Install the plugin using the `fuel` command line:

   ```
   fuel plugins --install influxdb_grafana-6.1-6.1.0-0.noarch.rpm
   ```

4. Verify that the plugin is installed correctly:

   ```
   fuel plugins
   ```

User Guide
==========

**InfluxDB-Grafana** plugin configuration
---------------------------------------------

1. Create a new environment with the Fuel UI wizard.
2. Add a node with the "Operating System" role.
3. Before applying changes or once changes applied, edit the name of the node by
   clicking on "Untitled (xx:yy)" and modify it for "influxdb".
4. Click on the Settings tab of the Fuel web UI.
5. Scroll down the page, select the "InfluxDB-Grafana Server plugin" checkbox
   and fill-in the required fields.
    - The name of the node where the plugin is deployed.
    - The password for root user.
    - The directory used to store metrics.
    - The name of a database where you want to store your metrics.
    - The username and its password for this specific database.

Here is screenshot of the fields

![InfluxDB-Grafana fields](./figures/influxdb-grafana-plugin.png "InfluxDB-Grafana fields")

Testing
-------

Once installed, you can check that InfluxDB is working using `curl`:

```
curl -G 'http://<HOST>:8086/db/lma/series?u=lma&p=<yourpassword>' --data-urlencode "q=select * from /.*/ limit 1"
```

Where `HOST` is the IP address or the name of the node that runs the server and
`yourpassword` is the password provided in the Fuel UI for the user of InfluxDB.
If you have some nodes that are reported to the InfluxDB server you should see
a long list of reported metrics in a table:
```
[{"name":"node-34.cpu.0.idle","columns" ... ]
```

If the table is empty you can use *netstat* to check that your server is listening
on port *8083, 8086, 8090* and *8099*.

To check that Grafana is running you need to check that *nginx* is listening
on port 80. A *curl* on port *80* on the host will retrieve an HTML document
with title set to Grafana.


Known issues
------------

None.

Release Notes
-------------

**6.1.0**

* Initial release of the plugin

Contributors
------------

* Guillaume Thouvenin <gthouvenin@mirantis.com>
* Simon Pasquier <spasquier@mirantis.com>
* Swann Croiset <scroiset@mirantis.com>
