.. _usage:

Exploring your time-series with Grafana
---------------------------------------

The InfluxDB-Grafana Plugin comes with a collection of predefined
dashboards you can use to visualize the time-series  stored in InfluxDB.

Please check the LMA Collector documentation for a complete list of all the
`metrics time-series <http://fuel-plugin-lma-collector.readthedocs.org/en/latest/appendix_b.html>`_
that are collected and stored in InfluxDB.

The Main Dashboard
++++++++++++++++++

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

The Nova dashboard
++++++++++++++++++

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

Self-monitoring dashboards
++++++++++++++++++++++++++

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


The hypervisor dashboard
++++++++++++++++++++++++

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

Other dashboards
++++++++++++++++

In total there are 19 different dashboards you can use to
explore different time-series facets of your OpenStack environment.

Viewing faults and anomalies
++++++++++++++++++++++++++++

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
++++++++++++++++++++++++++++

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