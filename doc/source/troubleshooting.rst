.. _troubleshooting:

Troubleshooting
---------------

If you get no data in Grafana, follow these troubleshooting tips.

#. First, check that the LMA Collector is running properly by following the
   LMA Collector troubleshooting instructions in the
   `LMA Collector Fuel Plugin User Guide <http://fuel-plugin-lma-collector.readthedocs.org/>`_.

#. Check that the nodes are able to connect to the InfluxDB cluster via the VIP address
   (see above how to get the InfluxDB cluster VIP address) on port *8086*::

     root@node-2:~# curl -I http://<VIP>:8086/ping

   The server should return a 204 HTTP status::

     HTTP/1.1 204 No Content
     Request-Id: cdc3c545-d19d-11e5-b457-000000000000
     X-Influxdb-Version: 0.10.0
     Date: Fri, 12 Feb 2016 15:32:19 GMT

#. Check that InfluxDB cluster VIP address is up and running::

     root@node-1:~# crm resource status vip__influxdb
     resource vip__influxdb is running on: node-1.test.domain.local

#. Check that the InfluxDB service is started on all nodes of the cluster::

     root@node-1:~# service influxdb status
     influxdb Process is running [ OK ]

#. If not, (re)start it::

     root@node-1:~# service influxdb start
     Starting the process influxdb [ OK ]
     influxdb process was started [ OK ]

#. Check that Grafana server is running::

     root@node-1:~# service grafana-server status
     * grafana is running

#. If not, (re)start it::

     root@node-1:~# service grafana-server start
     * Starting Grafana Server

#. If none of the above solves the problem, check the logs in ``/var/log/influxdb/influxdb.log``
   and ``/var/log/grafana/grafana.log`` to find out what might have gone wrong.