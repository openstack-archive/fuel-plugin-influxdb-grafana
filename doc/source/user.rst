.. _user_guide:

User Guide
==========

.. _plugin_configuration:

Plugin configuration
--------------------

To configure the **StackLight InfluxDB-Grafana Plugin**, you need to follow these steps:

1. `Create a new environment
   <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/create-environment/start-create-env.html>`_.

2. Click on the *Settings* tab of the Fuel web UI and select the *Other* category.

3. Scroll down through the settings until you find the **InfluxDB-Grafana Server
   Plugin** section. You should see a page like this:

   .. image:: ../images/influx_grafana_settings.png
      :width: 800

4. Tick the **InfluxDB-Grafana Plugin** box and fill-in the required fields as indicated below.

   a. Specify the number of days of retention for your data.
   b. Specify the InfluxDB admin password (called root password in the InfluxDB documentation).
   c. Specify the database name (default is lma).
   d. Specify the InfluxDB username and password.
   e. Specify the Grafana username and password.

5. Since the introduction of Grafana 2.6.0, the plugin now uses a MySQL database
   to store its configuration data such as the dashboard templates.

   a. Select **Local MySQL** if you want to create the Grafana database using the MySQL server
      of the OpenStack control-plane. Otherwise, select **Remote server** and specify
      the fully qualified name or IP address of the MySQL server you want to use.
   b. Then, specify the MySQL database name, username and password that will be used
      to access that database.

6. Tick the *Enable TLS for Grafana* box if you want to encrypt your
   Grafana credentials (username, password). Then, fill-in the required
   fields as indicated below.

   .. image:: ../images/tls_settings.png
      :width: 800

   a. Specify the DNS name of the Grafana server. This parameter is used
      to create a link in the Fuel dashboard to the Grafana server.
   #. Specify the location of a PEM file that contains the certificate
      and the private key of the Grafana server that will be used in TLS handchecks
      with the client.

7. Tick the *Use LDAP for Grafana authentication* box if you want to authenticate
   via LDAP to Grafana. Then, fill-in the required fields as indicated below.

   .. image:: ../images/ldap_auth.png
      :width: 800

   a. Select the *LDAPS* button if you want to enable LDAP authentication
      over SSL.
   #. Specify one or several LDAP server addresses separated by a space. Those
      addresses must be accessible from the node where Grafana is installed.
      Note that addresses external to the *management network* are not routable
      by default (see the note below).
   #. Specify the LDAP server port number or leave it empty to use the defaults.
   #. Specify the *Bind DN* of a user who has search priviliges on the LDAP server.
   #. Specify the password of the user identified by the *Bind DN* above.
   #. Specify the *Base DN* in the Directory Information Tree (DIT) from where
      to search for users.
   #. Specify a valid user search filter (ex. (uid=%s)).
      The result of the search should return a unique user entry.
   #. Specify a valid search filter to search for users.
      Example ``(uid=%s)``

   You can further restrict access to Grafana to those users who
   are member of a specific LDAP group.

   a. Tick the *Enable group-based authorization*.
   #. Specify the LDAP group *Base DN* in the DIT from where to search
      for groups.
   #. Specify the LDAP group search filter.
      Example ``(&(objectClass=posixGroup)(memberUid=%s))``
   #. Specify the CN of the LDAP group that will be mapped to the *admin role*
   #. Specify the CN of the LDAP group that will be mapped to the *viewer role*

   Users who have the *admin role* can modify the Grafana dashboards
   or create new ones. Users who have the *viewer role* can only
   visualise the Grafana dashboards.

7. `Configure your environment
   <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/configure-environment.html>`_.

   .. note:: By default, StackLight is configured to use the *management network*,
      of the so-called `Default Node Network Group
      <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/configure-environment/network-settings.html>`_.
      While this default setup may be appropriate for small deployments or
      evaluation purposes, it is recommended not to use this network
      for StackLight in production. It is instead recommended to create a network
      dedicated to StackLight using the `networking templates
      <https://docs.mirantis.com/openstack/fuel/fuel-8.0/operations.html#using-networking-templates>`_
      capability of Fuel. Using a dedicated network for StackLight will
      improve performances and reduce the monitoring footprint on the
      control-plane. It will also facilitate access to the Gafana UI
      after deployment as the *management network* is not routable.

8. Click the *Nodes* tab and assign the *InfluxDB_Grafana* role
   to the node(s) where you want to install the plugin.

   You can see in the example below that the *InfluxDB_Grafana*
   role is assigned to three nodes along side with the
   *Alerting_Infrastructure* and the *Elasticsearch_Kibana* roles.
   Here, the three plugins of the LMA toolchain backend servers are
   installed on the same nodes. You can assign the *InfluxDB_Grafana*
   role to either one node (standalone install) or three nodes for HA.

   .. image:: ../images/influx_grafana_role.png
      :width: 800

   .. note:: Installing the InfluxDB server on more than three nodes
      is currently not possible using the Fuel plugin.
      Similarly, installing the InfluxDB server on two nodes
      is not recommended to avoid split-brain situations in the Raft
      consensus of the InfluxDB cluster as well as the *Pacemaker* cluster
      which is responsible of the VIP address failover.
      To be also noted that it is possible to add or remove nodes
      with the *InfluxDB_Grafana* role in the cluster after deployment.

9. `Adjust the disk partitioning if necessary
   <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/configure-environment/customize-partitions.html>`_.

   By default, the InfluxDB-Grafana Plugin allocates:

     * 20% of the first available disk for the operating system by honoring
       a range of 15GB minimum to 50GB maximum.
     * 10GB for */var/log*.
     * At least 30 GB for the InfluxDB database in */var/lib/influxdb*.

10. `Deploy your environment
    <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/deploy-environment.html>`_.

.. _plugin_install_verification:

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

Exploring your time-series with Grafana
---------------------------------------

The InfluxDB-Grafana Plugin comes with a collection of predefined
dashboards you can use to visualize the time-series  stored in InfluxDB.

Please check the LMA Collector documentation for a complete list of all the
`metrics time-series <http://fuel-plugin-lma-collector.readthedocs.org/en/latest/appendix_b.html>`_
that are collected and stored in InfluxDB.

The Main Dashboard
~~~~~~~~~~~~~~~~~~

We suggest you start with the **Main Dashboard**, as shown
below, as an entry to the other dashboards.
The **Main Dashboard** provides a single pane of glass from where you can visualize the
overall health status of your OpenStack services such as Nova and Cinder
but also HAProxy, MySQL and RabbitMQ to name a few..

.. image:: ../images/grafana_main.png
   :width: 800

As you can see, the **Main Dashboard** (as most dashboards) provides
a drop down menu list in the upper left corner of the window
from where you can pick a particular metric dimension such as
the *controller name* or the *device name* you want to select.

In the example above, the system metrics of *node-48* are
being displayed in the dashboard.

Within the **OpenStack Services** row, each of the services
represented can be assigned five different status.

.. note:: The precise determination of a service health status depends
   on the correlation policies implemented for that service by a `Global Status Evaluation (GSE)
   plugin <http://fuel-plugin-lma-collector.readthedocs.org/en/latest/alarms.html#cluster-policies>`_.

The meaning associated with a service health status is the following:

- **Down**: One or several primary functions of a service
  cluster has failed. For example,
  all API endpoints of a service cluster like Nova
  or Cinder are failed.
- **Critical**: One or several primary functions of a
  service cluster are severely degraded. The quality
  of service delivered to the end-user should be severely
  impacted.
- **Warning**: One or several primary functions of a
  service cluster are slightly degraded. The quality
  of service delivered to the end-user should be slightly
  impacted.
- **Unknown**: There is not enough data to infer the actual
  health status of a service cluster.
- **Okay**: None of the above was found to be true.

The **Virtual Compute Resources** row provides an overview of
the amount of virtual resources being used by the compute nodes
including the number of virtual CPUs, the amount of memory
and disk space being used as well as the amount of virtual
resources remaining available to create new instances.

The "System" row provides an overview of the amount of physical
resources being used on the control plane (the controller cluster).
You can select a specific controller using the
controller's drop down list in the left corner of the toolbar.

The "Ceph" row provides an overview of the resources usage
and current health status of the Ceph cluster when it is deployed
in the OpenStack environment.

The **Main Dashboard** is also an entry point to access more detailed
dashboards for each of the OpenStack services that are monitored.
For example, if you click on the *Nova box*, the **Nova
Dashboard** is displayed.

.. image:: ../images/grafana_nova.png
   :width: 800

The Nova Dashboard
~~~~~~~~~~~~~~~~~~

The **Nova Dashboard** provides a detailed view of the
Nova service's related metrics.

The **Service Status** row provides information about the Nova service
cluster health status as a whole including the status of the API frontend
(the HAProxy public VIP), a counter of HTTP 5xx errors,
the HTTP requests response time and status code.

The **Nova API** row provides information about the current health status of
the API backends (nova-api, ec2-api, ...).

The **Nova Services** row provides information about the current and
historical status of the Nova *workers*.

The **Instances** row provides information about the number of active
instances in error and instances creation time statistics.

The **Resources** row provides various virtual resources usage indicators.

Self-Monitoring Dashboards
~~~~~~~~~~~~~~~~~~~~~~~~~~

The first **Self-Monitoring Dashboard** was introduced in LMA 0.8.
The intent of the self-monitoring dashboards is to bring operational
insights about how the monitoring system itself (the toolchain) performs overall.

The **Self-Monitoring Dashboard**, provides information about the *hekad*
and *collectd* processes.
In particular, it gives information about the amount of system resources
consumed by these processes, the time allocated to the Lua plugins
running within *hekad*, the amount of messages being processed and
the time it takes to process those messages.

Again, it is possible to select a particular node view using the drop down
menu list.

With LMA 0.9, we have introduced two new dashboards.

#. The **Elasticsearch Cluster Dashboard** provides information about
   the overall health status of the Elasticsearch cluster including
   the state of the shards, the number of pending tasks and various resources
   usage metrics.

#. The **InfluxDB Cluster Dashboard** provides statistics about the InfluxDB
   processes running in the InfluxDB cluster including various resources usage metrics.


The Hypervisor Dashboard
~~~~~~~~~~~~~~~~~~~~~~~~

LMA 0.9 introduces a new **Hypervisor Dashboard** which brings operational
insights about the virtual instances managed through *libvirt*.
As shown in the figure below, the **Hypervisor Dashboard** assembles a
view of various *libvirt* metrics. A dropdown menu list allows to pick
a particular instance UUID running on a particular node. In the
example below, the metrics for the instance id *ba844a75-b9db-4c2f-9cb9-0b083fe03fb7*
running on *node-4* are displayed.

.. image:: ../images/grafana_hypervisor.png
   :width: 800

Check the LMA Collector documentation for additional information about the
`*libvirt* metrics <http://fuel-plugin-lma-collector.readthedocs.org/en/latest/appendix_b.html#libvirt>`_
that are displayed in the **Hypervisor Dashboard**.

Other Dashboards
~~~~~~~~~~~~~~~~

In total there are 19 different dashboards you can use to
explore different time-series facets of your OpenStack environment.

Viewing Faults and Anomalies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The LMA Toolchain is capable of detecting a number of service-affecting
conditions such as the faults and anomalies that occured in your OpenStack
environment.
Those conditions are reported in annotations that are displayed in
Grafana. The Grafana annotations contain a textual
representation of the alarm (or set of alarms) that were triggered
by the Collectors for a service.
In other words, the annotations contain valuable insights
that you could use to diagnose and
troubleshoot problems. Furthermore, with the Grafana annotations,
the system makes a distinction between what is estimated as a
direct root cause versus what is estimated as an indirect
root cause. This is internally represented in a dependency graph.
There are first degree dependencies used to describe situations
whereby the health status of an entity
strictly depends on the health status of another entity. For
example Nova as a service has first degree dependencies
with the nova-api endpoints and the nova-scheduler workers. But
there are also second degree dependencies whereby the health
status of an entity doesn't strictly depends on the health status
of another entity, although it might, depending on other operations
being performed. For example, by default we declared that Nova
has a second degree dependency with Neutron. As a result, the
health status of Nova will not be directly impacted by the health
status of Neutron but the annotation will provide
a root cause analysis hint. Let's assume a situation
where Nova has changed from *okay* to *critical* status (because of
5xx HTTP errors) and that Neutron has been in *down* status for a while.
In this case, the Nova dashboard will display an annotation showing that
Nova has changed to a *warning* status because the system has detected
5xx errors and that it may be due to the fact that Neutron is *down*.
An example of what an annotation looks like is shown below.

.. image:: ../images/grafana_nova_annot.png
   :width: 800

This annotation shows that the health status of Nova is *down*
because there is no *nova-api* service backend (viewed from HAProxy)
that is *up*.

Hiding nodes from dashboards
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When you remove a node from the environment, it is still displayed in
the 'server' and 'controller' drop-down lists. To hide it from the list
you need to edit the associated InfluxDB query in the *templating* section.
For example, if you want to remove *node-1*, you need to add the following
condition to the *where* clause::

    and hostname != 'node-1'


.. image:: ../images/remove_controllers_from_templating.png

If you want to hide more than one node you can add more conditions like this::

    and hostname != 'node-1' and hostname != 'node-2'

This should be done for all dashboards that display the deleted node and you
need to save them afterwards.

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
