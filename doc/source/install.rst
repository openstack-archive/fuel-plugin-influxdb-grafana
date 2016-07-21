.. _user_installation:

Introduction
------------

You can install the StackLight InfluxDB-Grafana plugin using one of the
following options:

• Install using the RPM file
• Install from source

The following is a list of software components installed by the StackLight
InfluxDB-Grafana plugin:

+----------------+-------------------------------------+
| Components     | Version                             |
+================+=====================================+
| InfluxDB       | v0.11.1 for Ubuntu (64-bit)         |
+----------------+-------------------------------------+
| Grafana        | v3.0.4 for Ubuntu (64-bit)          |
+----------------+-------------------------------------+

Install using the RPM file of the Fuel plugins catalog
------------------------------------------------------

**To install the StackLight InfluxDB-Grafana Fuel plugin using the RPM file of
the Fuel plugins catalog:**

#. Go to the `Fuel Plugins Catalog
   <https://www.mirantis.com/validated-solution-integrations/fuel-plugins>`_.

#. From the :guilabel:`Filter` drop-down menu, select the Mirantis OpenStack
   version you are using and the :guilabel:`Monitoring` category.

#. Download the RPM file.

#. Copy the RPM file to the Fuel Master node:

   .. code-block:: console

      [root@home ~]# scp influxdb_grafana-0.10-0.10.0-1.noarch.rpm \
      root@<Fuel Master node IP address>:

#. Install the plugin using the `Fuel Plugins CLI
   <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/cli/cli_plugins.html>`_:

   .. code-block:: console

      [root@fuel ~]# fuel plugins --install influxdb_grafana-0.10-0.10.0-1.noarch.rpm

#. Verify that the plugin is installed correctly:

   .. code-block:: console

      [root@fuel ~]# fuel plugins --list
      id | name                 | version  | package_version
      ---|----------------------|----------|----------------
      1  | influxdb_grafana     | 0.10.0   | 4.0.0

Install from source
-------------------

Alternatively, you may want to build the RPM file of the plugin from source if,
for example, you want to test the latest features of the master branch or
customize the plugin.

.. note:: Running a Fuel plugin that you built yourself is at your own risk
   and will not be supported.

To install the StackLight InfluxDB-Grafana Plugin from source, first prepare
an environment to build the RPM file. The recommended approach is to build the
RPM file directly onto the Fuel Master node so that you will not have to copy
that file later on.

**To prepare an environment and build the plugin:**

#. Install the standard Linux development tools:

   .. code-block:: console

      [root@home ~] yum install createrepo rpm rpm-build dpkg-devel

#. Install the Fuel Plugin Builder. To do that, first get pip:

   .. code-block:: console

      [root@home ~] easy_install pip

#. Then install the Fuel Plugin Builder (the `fpb` command line) with `pip`:

   .. code-block:: console

      [root@home ~] pip install fuel-plugin-builder

   .. note:: You may also need to build the Fuel Plugin Builder if the package
      version of the plugin is higher than the package version supported by
      the Fuel Plugin Builder you get from `pypi`. For instructions on how to
      build the Fuel Plugin Builder, see the *Install Fuel Plugin Builder*
      section of the `Fuel Plugin SDK Guide <http://docs.openstack.org/developer/fuel-docs/plugindocs/fuel-plugin-sdk-guide/create-plugin/install-plugin-builder.html>`_.

#. Clone the plugin repository:

   .. code-block:: console

      [root@home ~] git clone https://github.com/openstack/fuel-plugin-influxdb-grafana.git

#. Verify that the plugin is valid:

   .. code-block:: console

      [root@home ~] fpb --check ./fuel-plugin-influxdb-grafana

#. Build the plugin:

   .. code-block:: console

      [root@home ~] fpb --build ./fuel-plugin-influxdb-grafana

**To install the plugin:**

Now that you have created the RPM file, install the plugin using the
:command:`fuel plugins --install` command:

.. code-block:: console

   [root@fuel ~] fuel plugins --install ./fuel-plugin-influxdb-grafana/*.noarch.rpm