..
 This work is licensed under a Creative Commons Attribution 3.0 Unported
 License.

http://creativecommons.org/licenses/by/3.0/legalcode

===========================================
Fuel plugin to install InfluxDB and Grafana
===========================================

https://blueprints.launchpad.net/fuel/+spec/influxdb-grafana-fuel-plugin

InfluxDB [#]_ is an open source, distributed, time series database for storing
metrics and events.  This plugin will also provide Grafana [#]_, an open
source, metrics dashboard and graph editor for exploring and visualizing the
data stored in InfluxDB.

Problem description
===================

A cloud operator needs a tool to store metrics and visualize them in an
efficient way.

Proposed change
===============

We will provide a set of tools that will improve the way we can explore and
visualize metrics. This plugin is configured to work out-of-the-box with the
LMA Collector [#]_ plugin. Alternatively, this plugin could work with Monasca
[#]_ and Gnocchi [#]_.

Alternatives
------------

* It might have been implemented as the part of Fuel core but we decided to
  make it as a plugin for several reasons:

  - This isn't something that all operators may want to deploy.

  - Any new additional functionality makes the project's testing more difficult,
    which is an additional risk for the Fuel release.

  - Ideally, this effort may be of interest for non-Fuel based deployments, too.

* Use Zabbix.

  - Zabbix stores metrics into a SQL database which doesn't scale well.

  - It offers limited capabilites for querying and displaying the data.

Data model impact
-----------------

None

REST API impact
---------------

None

Upgrade impact
--------------

None

Security impact
---------------

None

Notifications impact
--------------------

None

Other end user impact
---------------------

None

Performance Impact
------------------

The amount of resources (RAM, CPU, disk) required for InfluxDB depends on the
number of clients and on the number of collected metrics. There is no sizing
number references yet. Therefore, in order to avoid resource conflicts with
other applications, it is recommended to deploy the InfluxDB plugin on a
dedicated node.

Other deployer impact
---------------------

To be useful the InfluxDB server needs to be fed with operational data. This
can be achieved by integrating the InfluxDB plugin with the LMA Collector
plugin or other compatible systems.

Developer impact
----------------

None

Implementation
==============

Assignee(s)
-----------

Primary assignee:
  Simon Pasquier <spasquier@mirantis.com> (feature lead, developer)

Other contributors:
  Irina Povolotskaya <ipovolotskaya@mirantis.com> (technical writer)
  Guillaume Thouvenin <gthouvenin@mirantis.com> (developer)
  Swann Croiset <scroiset@mirantis.com> (developer)


Work Items
----------

* Implement the InfluxDB Grafana plugin.

* Implement the Puppet manifests.

* Testing.

* Write the documentation.

Dependencies
============

* Fuel 6.1 and higher.

* It will be installed through the empty role artifact [#]_.


Testing
=======

* Prepare a test plan.

* Test the plugin by deploying environments with all Fuel deployment modes.

* Integration tests with LMA collector.

Documentation Impact
====================

* Deployment Guide

* User Guide (what features the plugin provides, how to use them in the
  deployed OpenStack environment).

* Test Plan.

* Test Report.

References
==========

.. [#] http://www.influxdb.com/

.. [#] http://www.grafana.org/

.. [#] https://blueprints.launchpad.net/fuel/+spec/lma-collector-plugin

.. [#] https://launchpad.net/monasca

.. [#] https://github.com/stackforge/gnocchi

.. [#] https://blueprints.launchpad.net/fuel/+spec/blank-role-node
