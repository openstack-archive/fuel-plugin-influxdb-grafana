.. _user_overview:

Overview
========

The **InfluxDB-Grafana Fuel Plugin** is used to install and configure
InfluxDB and Grafana which collectively provide access to the OpenStack
metrics analytics. InfluxDB is a powerful distributed time-series database
to store and search metrics time-series. The metrics analytics are used to
visualize the time-series and the annotations produced by the LMA Collector.
The annotations contain insightful information about the detected fault
or anomaly that triggered a change of state for a node cluster or service
cluster as well as textual hints about what might be the root cause of the
fault or anomaly.
The InfluxDB-Grafana Plugin is an indispensable tool to answering
the questions "what has changed, when and why?". Grafana is installed with
a collection of predefined dashboards for each of the OpenStack services.
Among those, the *Main Dashboard* provides a single pane of glass overview
of your OpenStack environment status.

The InfluxDB-Grafana Plugin is a key component of the
**Logging, Monitoring and Alerting (LMA) Toolchain** of Mirantis OpenStack.

.. _plugin_requirements:

Requirements
------------

+----------------------------+--------------------------------------------------------------------------------------------+
| **Requirement**            | **Version/Comment**                                                                        |
+============================+============================================================================================+
| Fuel                       | Mirantis OpenStack 7.0                                                                     |
+----------------------------+--------------------------------------------------------------------------------------------+
| Hardware configuration     | The hardware configuration (RAM, CPU, disk(s)) required by this plugin depends on the size |
|                            | of your cloud environment and other factors like the retention policy, but a typical setup |
|                            | would at least require a quad-core server with 8GB of RAM and access to a fast disk or     |
|                            | disks array (ideally, SSDs).                                                               |
|                            | It is also highly recommended to use a dedicated disk for your data storage. Otherwise,    |
|                            | The InfluxDB-Grafana Plugin will use the root filesystem by default.                       |
+----------------------------+--------------------------------------------------------------------------------------------+

Limitations
-----------

A current limitation of this plugin is that it not possible to display in the Fuel web UI,
the URL where the Grafana interface can be reached when the deployment has completed.
Instructions are provided in the *Installation Guide* about how you can
obtain this URL using the `fuel` command line.

Key terms, acronyms and abbreviations
-------------------------------------

+----------------------------+--------------------------------------------------------------------------------------------+
| **Terms & acronyms**       | **Definition**                                                                             |
+============================+============================================================================================+
| LMA Collector              | Logging, Monitoring and Alerting (LMA) Collector. A service running on each node which     |
|                            | collects all the logs and the OpenStak notifications.                                      |
+----------------------------+--------------------------------------------------------------------------------------------+
| InfluxDB                   | InfluxDB is a time-series, metrics, and analytics open-source database (MIT license).      |
|                            | It’s written in Go and has no external dependencies.                                       |
|                            | InfluxDB is targeted at use cases for DevOps, metrics, sensor data, and real-time          |
|                            | analytics.                                                                                 |
+----------------------------+--------------------------------------------------------------------------------------------+
| Grafana                    | Grafana is an (Apache 2.0 Licensed) general purpose dashboard and graph composer.          |
|                            | It's focused on providing rich ways to visualize metrics time-series, mainly though graphs |
|                            | but supports other ways to visualize data through a pluggable panel architecture.          |
|                            | It currently has rich support for Graphite, InfluxDB and OpenTSDB. But supports other data |
|                            | sources via plugins. Grafana is most commonly used for infrastructure monitoring,          |
|                            | application monitoring and metric analytics.                                               |
+----------------------------+--------------------------------------------------------------------------------------------+
