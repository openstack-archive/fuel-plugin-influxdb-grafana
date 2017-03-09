.. _plugin_limitations:

Limitations
-----------

The StackLight InfluxDB-Grafana plugin 1.1.0 has the following limitation:

* InfluxDB isn't deployed in cluster mode because it is only supported by the
  commercial version of InfluxDB. Instead it is deployed in standalone mode on
  each node and only one instance receives the datapoints at a given time and
  the other nodes will be used as failover in case the first node dies.
