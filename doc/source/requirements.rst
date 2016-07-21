.. _plugin_requirements:

Requirements
------------

+-----------------------+------------------------------------------------------------------------+
| **Requirement**       | **Version/Comment**                                                    |
+=======================+========================================================================+
| Disk space            | The plugin’s specification requires provisioning at least 15 GB of disk|
|                       | space for the system, 10 GB for the logs, and 30 GB for the database.  |
|                       | Therefore, the installation of the plugin will fail if there is less   |
|                       | than 55 GB of disk space available on the node.                        |
+-----------------------+------------------------------------------------------------------------+
| Mirantis OpenStack    | 8.0, 9.0                                                               |
+-----------------------+------------------------------------------------------------------------+
| Hardware configuration| The hardware configuration (RAM, CPU, disk(s)) required by this plugin |
|                       | depends on the size of your cloud environment and other factors like   |
|                       | the retention policy. An average setup would require a quad-core       |
|                       | server with 8 GB of RAM and access to a 500-1000 IOPS disk.            |
|                       | See the `InfluxDB Hardware Sizing Guide                                |
|                       | <https://docs.influxdata.com/influxdb/v0.10/guides/hardware_sizing/>`_ |
|                       | for additional sizing information.                                     |
|                       |                                                                        |
|                       | It is highly recommended that you use a dedicated disk for your data   |
|                       | storage. Otherwise, the InfluxDB-Grafana Plugin will use the root      |
|                       | file system by default.                                                |
+-----------------------+------------------------------------------------------------------------+