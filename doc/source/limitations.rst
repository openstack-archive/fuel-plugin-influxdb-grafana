.. _plugin_limitations:

Limitations
-----------

Currently, the size of an InfluxDB cluster the Fuel plugin can deploy is limited to three nodes. In addition to this,
each node of the InfluxDB cluster is configured to run under the *meta* node role and the *data* node role. Therefore,
it is not possible to separate the nodes participating in the Raft consensus cluster from
the nodes accessing the data replicas.