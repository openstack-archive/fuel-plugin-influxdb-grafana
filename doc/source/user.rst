.. _user_guide:

User Guide
==========

.. _plugin_configuration:

Plugin configuration
--------------------

To configure your plugin, you need to follow these steps:

#. `Create a new environment <http://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#launch-wizard-to-create-new-environment>`_
   with the Fuel web user interface.

#. Click on the Settings tab of the Fuel web UI.

#. Scroll down the page and select the InfluxDB-Grafana Plugin in the left column.
   The InfluxDB-Grafana Plugin settings screen should appear as shown below.

   .. image:: ../images/influx_grafana_settings.png
      :width: 800
      :align: center

#. Select the InfluxDB-Grafana Plugin checkbox and fill-in the required fields.

   a. Specify the number of days retention period for data.

   #. Specify the InfluxDB admin password (called root password in the InfluxDB documentation).

   #. Specify the database name (default is lma).

   #. Specify the InfluxDB user name and password.

   #. Specify the Grafana user name and password.

#. Assign the *InfluxDB Grafana* role to the node where you would like to install
   the InfluxDB and Grafana servers as shown below.

   .. image:: ../images/influx_grafana_role.png
      :width: 800
      :align: center

   .. note:: Because of a bug with Fuel 7.0 (see bug `#1496328
      <https://bugs.launchpad.net/fuel-plugins/+bug/1496328>`_), the UI won't let
      you assign the *InfluxDB Grafana* role if at least one node is already
      assigned with one of the built-in roles.

      To workaround this problem, you should either remove the already assigned built-in roles or use the Fuel CLI::

      $ fuel --env <environment id> node set --node-id <node_id> --role=influxdb_grafana

#. Adjust the disk configuration if necessary (see the `Fuel User Guide
   <http://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#disk-partitioning>`_
   for details). By default, the InfluxDB-Grafana Plugin allocates:

   * 20% of the first available disk for the operating system by honoring a range of 15GB minimum to 50GB maximum.
   * 10GB for */var/log*.
   * At least 30 GB for the InfluxDB database in */opt/influxdb*.

#. `Configure your environment <http://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#configure-your-environment>`_
   as needed.

#. `Verify the networks <http://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#verify-networks>`_ on the Networks tab of the Fuel web UI.

#. `Deploy <http://docs.mirantis.com/openstack/fuel/fuel-7.0/user-guide.html#deploy-changes>`_ your changes.

.. _plugin_install_verification:

Plugin verification
-------------------

Be aware, that depending on the number of nodes and deployment setup,
deploying a Mirantis OpenStack environment can typically take anything
from 30 minutes to several hours. But once your deployment is complete,
you should see a notification that looks like the following:

   .. image:: ../images/deployment_notification.png
      :width: 800
      :align: center

Verifying InfluxDB
~~~~~~~~~~~~~~~~~~
Once your deployment has completed, you should verify that InfluxDB is
running properly. On the Fuel Master node, you can retrieve the IP
address of the node where InfluxDB is installed via the `fuel` command line::

    [root@fuel ~]# fuel nodes
    id | status   | name             | cluster | ip        | mac               | roles                | pending_roles | online | group_id
    ---|----------|------------------|---------|-----------|-------------------|----------------------|---------------|--------|---------
    37 | ready    | Untitled (47:b7) | 38      | 10.20.0.4 | 08:00:27:54:47:b7 | influxdb_grafana     |               | True   | 38

    [Skip ...]

On that node (node-37 in this example), the *influx* command should be
available via the CLI. Executing *influx* will start an interactive CLI
and automatically connect to the local InfluxDB server::

    [root@node-37 ~]# /opt/influxdb/influx -database lma -password lmapass --username lma
    Connected to http://localhost:8086 version 0.9.4.2
    InfluxDB shell 0.9.4.2
    >

Then if you type::

    > show series

You should see a dump of all the time-series collected so far::

    [ Skip...]

    name: swap_used
    ---------------
    _key                                                deployment_id   hostname
    swap_used,deployment_id=38,hostname=node-40 38              node-40
    swap_used,deployment_id=38,hostname=node-42 38              node-42
    swap_used,deployment_id=38,hostname=node-41 38              node-41
    swap_used,deployment_id=38,hostname=node-43 38              node-43
    swap_used,deployment_id=38,hostname=node-38 38              node-38
    swap_used,deployment_id=38,hostname=node-37 38              node-37
    swap_used,deployment_id=38,hostname=node-36 38              node-36


    name: total_threads_created
    ---------------------------
    _key                                                        deployment_id   hostname
    total_threads_created,deployment_id=38,hostname=node-38     38              node-38
    total_threads_created,deployment_id=38,hostname=node-37     38              node-37
    total_threads_created,deployment_id=38,hostname=node-36     38              node-36

Verifying Grafana
~~~~~~~~~~~~~~~~~

The Grafana user interface runs on port 8000.
Pointing your browser to the URL http://<HOST>:8000/ you should see the
Grafana login page:

.. image:: ../images/grafana_login.png
   :align: center
   :width: 800


You should be redirected to the Grafana *Home Page*.
The first time you access Grafana, you are requested to
authenticate using the credentials you have defined in the settings.
Once you have authenticated successfully, you should be automatically
redirected to the *Home Page* from where you can select a dashboard as
shown below.

.. image:: ../images/grafana_home.png
   :align: center
   :width: 800

Exploring your time-series with Grafana
---------------------------------------

The InfluxDB-Grafana Plugin comes with a collection of predefined
dashboards you can use to visualize the time-series that are
stored in InfluxDB. There is one primary dashboard, called the
*Main Dashboard*, and several other dashboards that are organized
per service name.

The Main Dashboard
~~~~~~~~~~~~~~~~~~

We suggest you start with the *Main Dashboard*, as shown
below. The *Main Dashboard* provides a
single pane of glass to visualize the health
status of all the OpenStack services being monitored
such as Nova or Cinder but also HAProxy, MySQL and RabbitMQ.

.. image:: ../images/grafana_main.png
   :align: center
   :width: 800

As you can see, the *Main Dashboard* (as most dashboards) provides
a drop down menu list in the upper left corner of the window
from where you can select a metric tag (a.k.a dimension) such as
a controller name or device name you want to visualize.
In the example above, we say we want to visualize the
system time-series for *node-48*.

Within the *OpenStack Services* row, each of the services
represented can be assigned five different states.

.. note:: The precise determination of a service state depends
   on the Global Status Evaluation (GSE) policies defined
   for the *GSE Plugins*.

The meaning associated with a service health state is the following:

* **Down**: One or several primary functions of a service
  cluster are failed. For example,
  all API endpoints of a service cluster like Nova
  or Cinder are failed.
* **Critical**: One or several primary functions of a
  service cluster are severely degraded. The quality
  of service delivered to the end-user should be severely
  impacted.
* **Warning**: One or several primary functions of a
  service cluster are slightly degraded. The quality
  of service delivered to the end-user should be slightly
  impacted.
* **Unknown**: There is not enough data to infer the actual
  health state of a service cluster.
* **Okay**: None of the above was found to be true.

The *Virtual Compute Resources* row provides an overview of
the amount of virtual resources being used by the compute nodes
including the number of virtual CPUs, the amount of memory
and disk space being used as well as the amount of virtual
resources remaining available to create new instances.

The "System" row provides an overview of the amount of physical
resources being used on the control plane (the controller cluster).
You can select a specific controller using the
controller's drop down list in the left corner of the toolbar.

The "Ceph" row provides an overview of the resources usage
and current health state of the Ceph cluster when it is deployed
in the OpenStack environment.

The *Main Dashboard* is also an entry point to access detailed
dashboards for each of the OpenStack services being monitored.
For example, if you click through the Nova box, you should see
a screen like this:

   .. image:: ../images/grafana_nova.png
      :align: center
      :width: 800


The Nova Dashboard
~~~~~~~~~~~~~~~~~~

The *Nova Dashboard* provides a detailed view of the
Nova service's related metrics.

The *Service Status* row provides information about the Nova service
cluster health state as a whole including the state of the API frontend
(the HAProxy plubic VIP), a counter of HTTP 5xx errors,
the HTTP requests response time and status code.

The *Nova API* row provides information about the health state of
the API backends (nova-api, ec2-api, ...), the state of the workers
and compute nodes.

The *Instance* row provides information about the number of
active instances, instances in error and instances creation time
statistics.

The "Resources" row provides various virtual resources usage indicators.

The LMA Self-Monitoring Dashboard
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The *LMA Self-Monitoring Dashboard* is a new dashboard in LMA 0.8.
This dashboard provides an overview of how the LMA Toolchain
performs overall.

The *LMA Collector* row provides information about the Heka process.
In particular, it is possible to visualize the
processing time allocated to the Lua plugins and the amount of messages
that have been processed as well as the amount of system resources
consumed by the Heka process.

Again, it is possible to select a particular node using the dropdown
menu list.

The *Collectd* row provides system resource usage information allocated
to the *collectd* process.

The *InfluxDB* row provides system resource usage information allocated
to the *InfluxDB* application.

The *Grafana* row provides system resource usage information allocated
to the *Grafana* application.

The *Elasticsearch* row provides system resource usage information allocated
to the JVM process running the Elasticsearch application.

Other Dashboards
~~~~~~~~~~~~~~~~

In total there are 16 different dashboards you can use to
explore different time-series facettes of your OpenStack environment.

Viewing Faults and Anomalies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The LMA-Toolchain is capable of detecting a number of service-affecting
conditions such as the faults and anomalies that occured in your OpenStack
environment.
Those conditions are reported in annotations that are displayed in
Grafana. The Grafana annotations contain a textual
representation of the alarm (or set of alarms) that were triggered
by the Collectors for a service.
In other words, the annotations contain valuable insights
that you could use to diagnose and
troubleshoot problems. Futhermore, with the Grafana annotations,
the system makes a distiction between what is estimated as a
direct root cause versus what is estimated as an indirect
root cause. This is internally represented in a dependency graph.
There are first degree dependencies that are used
to describe situations whereby the health state of an entity
strictly depends on the health state of another entity. For
example Nova as a service has first degree dependencies
with the nova-api endpoints and the nova-scheduler workers. But
there are also second degree dependencies whereby the health
state of an entity doesn't strictly depends on the heath state
of another entity although it might be depending on the operation
being performed. For example, by default we declared that Nova
has a second degree dependency with Neutron. As a result, the
health state of Nova will not be directly impacted by the health
state of Neutron but the annotation will provide
a root cause analysis hint. For example, let's assume a situation
where Nova has changed a state from *okay* to *critical* (because of
5xx HTTP errors) and that Neutron has been in *down* state for a while.
In this case, the Nova dashboard will display an annotation that says
Nova has changed a state to *warning* because the system has detected
5xx errors and that it may be due to the fact that Neutron is *down*.
An example of what an annotation looks like is shown below.

   .. image:: ../images/grafana_nova_annot.png
      :align: center
      :width: 800


Troubleshooting
---------------

If you get no data in Grafana, follow these troubleshooting tips.

#. First, check that the LMA Collector is running properly by following the
   LMA Collector troubleshooting instructions in the
   `LMA Collector Fuel Plugin User Guide <http://fuel-plugin-lma-collector.readthedocs.org/>`_.

#. Check that the nodes are able to connect to the InfluxDB server on port *8086*.

#. Check that InfluxDB is running::

    [root@node-37 ~]# /etc/init.d/influxdb status
    influxdb Process is running [ OK ]

#. If InfluxDB is down, restart it::

    [root@node-37 ~]# /etc/init.d/influxdb start
    Starting the process influxdb [ OK ]
    influxdb process was started [ OK ]

#. Check that Grafana is running::

    [root@node-37 ~]# /etc/init.d/grafana-server status
    * grafana is running

#. If Grafana is down, restart it::

    [root@node-37 ~]# /etc/init.d/grafana-server start
    * Starting Grafana Server

#. If none of the above solve the problem, check the logs in ``/var/log/influxdb/influxdb.log``
   and ``/var/log/grafana/grafana.log`` to find out what might have gone wrong.
