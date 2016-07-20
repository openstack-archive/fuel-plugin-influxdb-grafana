.. _release_notes:

Release notes
-------------

0.10.0
++++++

* Changes

  * Add support for LDAP(S) authentication to access Grafana.
  * Add support for TLS encryption to access Grafana.
    A PEM file obtained by concatenating the SSL certificate with the private key
    of the server must be provided in the settings of the plugin to configure the
    TLS termination.
  * Upgrade to InfluxDB v0.11.1.
  * Upgrade to Grafana v3.0.4.

0.9.0
+++++

- A new dashboard for hypervisor metrics.
- A new dashboard for InfluxDB cluster.
- A new dashboard for Elasticsearch cluster.
- Upgrade to Grafana 2.6.0.
- Upgrade to InfluxDB 0.10.0.
- Add support for InfluxDB clustering (beta state).
- Use MySQL as Grafana backend to support HA.

0.8.0
+++++

- Add support for the "influxdb_grafana" Fuel Plugin role instead of
  the "base-os" role which had several limitations.
- Add support for retention policy configuration.
- Upgrade to InfluxDB 0.9.4 which brings metrics time-series with tagging.
- Upgrade to Grafana 2.5.0.
- Several dashboard visualisation improvements.
- A new self-monitoring dashboard.

0.7.0
+++++

- Initial release of the plugin. This is a beta version.