.. _verification:

Plugin verification
-------------------

Be aware that depending on the number of nodes and deployment setup,
deploying a Mirantis OpenStack environment can typically take anything
from 30 minutes to several hours. But once your deployment is complete,
you should see a notification message indicating that you deployment
successfully completed as in the figure below.

.. image:: ../images/deployment_notification.png
   :width: 800

Verifying InfluxDB
~~~~~~~~~~~~~~~~~~

You should verify that the InfluxDB cluster is running properly.
First, you need first to retreive the InfluxDB cluster VIP address.
Here is how to proceed.

#. On the Fuel Master node, find the IP address of a node where the InfluxDB
   server is installed using the following command::

    [root@fuel ~]# fuel nodes
    id | status   | name             | cluster | ip         | mac | roles            |
    ---|----------|------------------|---------|------------|-----|------------------|
    1  | ready    | Untitled (fa:87) | 1       | 10.109.0.8 | ... | influxdb_grafana |
    2  | ready    | Untitled (12:aa) | 1       | 10.109.0.3 | ... | influxdb_grafana |
    3  | ready    | Untitled (4e:6e) | 1       | 10.109.0.7 | ... | influxdb_grafana |


#. Then `ssh` to anyone of these nodes (ex. *node-1*) and type the command::

    root@node-1:~# hiera lma::influxdb::vip
    10.109.1.4

   This tells you that the VIP address of your InfluxDB cluster is *10.109.1.4*.

#. With that VIP address type the command::

     root@node-1:~# /usr/bin/influx -database lma -password lmapass \
     --username root -host 10.109.1.4 -port 8086
     Visit https://enterprise.influxdata.com to register for updates,
     InfluxDB server management, and monitoring.
     Connected to http://10.109.1.4:8086 version 0.10.0
     InfluxDB shell 0.10.0
     >

   As you can see, executing */usr/bin/influx* will start an interactive CLI and automatically connect to
   the InfluxDB server. Then if you type::

     > show series

   You should see a dump of all the time-series collected so far.
   Then, if you type::

     > show servers
     name: data_nodes
     ----------------
     id      http_addr       tcp_addr
     1       node-1:8086     node-1:8088
     3       node-2:8086     node-2:8088
     5       node-3:8086     node-3:8088

     name: meta_nodes
     ----------------
     id      http_addr       tcp_addr
     1       node-1:8091     node-1:8088
     2       node-2:8091     node-2:8088
     4       node-3:8091     node-3:8088

   You should see a list of the nodes participating in the `InfluxDB cluster
   <https://docs.influxdata.com/influxdb/v0.10/guides/clustering/>`_ with their roles (data or meta).


Verifying Grafana
~~~~~~~~~~~~~~~~~

From the Fuel dDashboard, click on the **Grafana** link (or enter the IP address
and port number if your DNS is not setup).
The first time you access Grafana, you are requested to
authenticate using your credentials.

.. image:: ../images/grafana_login.png
   :width: 800

Then you should be redirected to the *Grafana Home Page*
from where you can select a dashboard as shown below.

.. image:: ../images/grafana_home.png
   :width: 800