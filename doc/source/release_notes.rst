.. _release_notes:

Release notes
-------------

Version 1.1.0
+++++++++++++

Version 1.0.0
+++++++++++++

Breaking changes
''''''''''''''''

Upgrade to InfluxDB 1.1 which drops the clustering support. InfluxDB is now
deployed in standalone mode on each node and only one instance receives the
datapoints at a given time and the other nodes will be used as failover in case
the first node dies.

Features
''''''''

* Upgrade to Grafana 4.1.1
* Added an option to store the InfluxDB WAL in memory. This option is disabled
  by default.

Fixes
'''''

* Updated the documentation to emphasize the need to use fast disks, such as
  SSDs.
* Added support for wildcard SSL certificates. See
  `#1608665 <https://bugs.launchpad.net/lma-toolchain/+bug/1608665>`_.
* Fixed the UI issue with the LDAP protocol radio button. See
  `#1599778 <https://bugs.launchpad.net/lma-toolchain/+bug/1599778>`_.
* Prevent co-installation with the Contrail plugin.
  See `#1646550 <https://bugs.launchpad.net/lma-toolchain/+bug/1646550>`_.

Version 0.10.0
++++++++++++++

The StackLight InfluxDB-Grafana plugin 0.10.0 contains the following updates:

* Added support for LDAP(S) authentication to access Grafana.
* Added support for TLS encryption to access Grafana. A PEM file obtained by
  concatenating the SSL certificate with the private key of the server must be
  provided in the settings of the plugin to configure the TLS termination.
* Upgraded to InfluxDB v0.11.1.
* Upgraded to Grafana v3.0.4.

Version 0.9.0
+++++++++++++

The StackLight InfluxDB-Grafana plugin 0.9.0 contains the following updates:

* Added a new dashboard for hypervisor metrics.
* Added a new dashboard for InfluxDB cluster.
* Added a new dashboard for Elasticsearch cluster.
* Upgraded to Grafana 2.6.0.
* Upgraded to InfluxDB 0.10.0.
* Added support for InfluxDB clustering (beta state).
* Added the capability to use MySQL as Grafana back end to support HA.

Version 0.8.0
+++++++++++++

The StackLight InfluxDB-Grafana plugin 0.8.0 contains the following updates:

* Added support for the ``influxdb_grafana`` Fuel plugin role instead of the
  ``base-os`` role which had several limitations.
* Added support for retention policy configuration.
* Upgraded to InfluxDB 0.9.4 which brings metrics time-series with tagging.
* Upgraded to Grafana 2.5.0.
* Improved dashboard visualization.
* Added a new self-monitoring dashboard.

Version 0.7.0
+++++++++++++

The initial release of the plugin. This is a beta version.
