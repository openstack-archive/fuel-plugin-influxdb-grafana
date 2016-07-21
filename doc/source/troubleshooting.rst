.. _troubleshooting:

Troubleshooting
---------------

If Grafana contains no data, use the following troubleshooting tips:

#. Verify that the StackLight Collector is running properly by following the
   troubleshooting instructions in the
   `StackLight Collector Fuel plugin documentation <http://fuel-plugin-lma-collector.readthedocs.org/>`_.

#. Verify that the nodes are able to connect to the InfluxDB cluster through
   the VIP address (See the *Verify InfluxDB* section for instructions on how
   to get the InfluxDB cluster VIP address) on port *8086*:

   .. code-block:: console

      root@node-2:~# curl -I http://<VIP>:8086/ping

   The server should return a 204 HTTP status:

   .. code-block:: console

      HTTP/1.1 204 No Content
      Request-Id: cdc3c545-d19d-11e5-b457-000000000000
      X-Influxdb-Version: 0.10.0
      Date: Fri, 12 Feb 2016 15:32:19 GMT

#. Verify that InfluxDB cluster VIP address is up and running:

   .. code-block:: console

      root@node-1:~# crm resource status vip__influxdb
      resource vip__influxdb is running on: node-1.test.domain.local

#. Verify that the InfluxDB service is running on all nodes of the cluster:

   .. code-block:: console

      root@node-1:~# service influxdb status
      influxdb Process is running [ OK ]

#. If the InfluxDB service is not running, restart it:

   .. code-block:: console

      root@node-1:~# service influxdb start
      Starting the process influxdb [ OK ]
      influxdb process was started [ OK ]

#. Verify that the Grafana server is running:

   .. code-block:: console

      root@node-1:~# service grafana-server status
      * grafana is running

#. If the Grafana server is not running, restart it:

   .. code-block:: console

      root@node-1:~# service grafana-server start
      * Starting Grafana Server

#. If none of the above solves the issue, look for errors in the following log
   files:

   * InfluxDB -- ``/var/log/influxdb/influxdb.log``
   * Grafana -- ``/var/log/grafana/grafana.log``