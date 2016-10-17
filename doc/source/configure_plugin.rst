.. _plugin_configuration:

.. raw:: latex

   \pagebreak

Plugin configuration
--------------------

**To configure the StackLight InfluxDB-Grafana plugin:**

#. Create a new environment as described in `Create a new OpenStack environment
   <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/create-environment/start-create-env.html>`_.

#. In the Fuel web UI, click the :guilabel:`Settings` tab and select the
   :guilabel:`Other` category.

#. Scroll down through the settings until you find
   :guilabel:`The StackLight InfluxDB-Grafana Server Plugin` section:

   .. image:: ../images/influx_main_settings.png
      :width: 450pt

#. Select :guilabel:`The StackLight InfluxDB-Grafana Server Plugin` and fill
   in the required fields as indicated below.

   a. Specify the number of days of retention for your data.
   #. Specify the InfluxDB admin password (called root password in the InfluxDB
      documentation).
   #. Specify the database name (the default is ``lma``).
   #. Specify the InfluxDB username and password.
   #. To store the Write-Ahead-Log files in a temporary file storage instead
      of the disk, select :guilabel:`Store WAL files in memory`. This will
      improve performance but the data can be lost.
   #. Specify the Grafana username and password.

#. The plugin uses a MySQL database to store its configuration data, such as
   the dashboard templates.

   .. image:: ../images/influx_mysql_settings.png
      :width: 450pt

   a. Select :guilabel:`Local MySQL` if you want to create the Grafana
      database using the MySQL server of the OpenStack control plane.
      Otherwise, select :guilabel:`Remote server` and specify the fully
      qualified name or the IP address of the MySQL server you want to use.
   #. Specify the MySQL database name, username, and password that will be used
      to access that database.

#. Select :guilabel:`Enable TLS for Grafana` if you want to encrypt your
   Grafana credentials (username, password). Then, fill in the required
   fields as indicated below.

   .. image:: ../images/influx_tls_settings.png
      :width: 450pt

   a. Specify the DNS name of the Grafana server. This parameter is used to
      create a link in the Fuel dashboard to the Grafana server.
   #. Specify the location of a PEM file that contains the certificate and the
      private key of the Grafana server that will be used in TLS handchecks
      with the client.

#. Select :guilabel:`Use LDAP for Grafana authentication` if you want to
   authenticate to Grafana through LDAP. Then, fill in the required fields as
   indicated below.

   .. image:: ../images/influx_ldap_settings.png
      :width: 450pt

   a. Select :guilabel:`LDAPS` if you want to enable LDAP authentication over
      SSL.
   #. Specify one or several LDAP server addresses separated by space. These
      addresses must be accessible from the node where Grafana is installed.
      Addresses outside the *management network* are not routable by default
      (see the note below).
   #. Specify the LDAP server port number or leave it empty to use the
      defaults.
   #. Specify the :guilabel:`Bind DN` of a user who has search privileges on
      the LDAP server.
   #. Specify the password of the user identified by the :guilabel:`Bind DN`
      above.
   #. Specify the :guilabel:`User search base DN` in the Directory Information
      Tree (DIT) from where to search for users.
   #. Specify a valid user search filter, for example, ``(uid=%s)``. The
      result of the search should be a unique user entry.

   You can further restrict access to Grafana to those users who are members
   of a specific LDAP group.

   a. Select :guilabel:`Enable group-based authorization`.
   #. Specify the LDAP group :guilabel:`Base DN` in the DIT from where to
      search for groups.
   #. Specify the LDAP group search filter. For example,
      ``(&(objectClass=posixGroup)(memberUid=%s))``.
   #. Specify the CN of the LDAP group that will be mapped to the *admin role*.
   #. Specify the CN of the LDAP group that will be mapped to the *viewer role*.

   Users who have the *admin role* can modify the Grafana dashboards or create
   new ones. Users who have the *viewer role* can only visualize the Grafana
   dashboards.

#. Configure your environment as described in `Configure your Environment
   <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/configure-environment.html>`_.

   .. note:: By default, StackLight is configured to use the *management
      network* of the so-called `Default Node Network Group
      <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/configure-environment/network-settings.html>`_.
      While this default setup may be appropriate for small deployments or
      evaluation purposes, it is recommended that you not use this network for
      StackLight in production. Instead, create a network dedicated to
      StackLight using the `networking templates
      <https://docs.mirantis.com/openstack/fuel/fuel-9.0/operations.html#using-networking-templates>`_
      Fuel capability. Using a dedicated network for StackLight will improve
      performance and reduce the monitoring footprint on the control plane. It
      will also facilitate access to the Gafana UI after deployment, as the
      *management network* is not routable.

#. Click the :guilabel:`Nodes` tab and assign the :guilabel:`InfluxDB_Grafana`
   role to the node or multiple nodes where you want to install the plugin.

   The example below shows that the :guilabel:`InfluxDB_Grafana` role is
   assigned to three nodes alongside with the
   :guilabel:`Alerting_Infrastructure` and the
   :guilabel:`Elasticsearch_Kibana` roles. The three plugins of the LMA
   toolchain back-end servers are installed on the same nodes. You can assign
   the :guilabel:`InfluxDB_Grafana` role to either one node (standalone
   install) or three nodes for HA.

   .. image:: ../images/influx_grafana_role.png
      :width: 450pt

   .. note:: Currently, installing the InfluxDB server on more than three
      nodes is not possible using the Fuel plugin. Similarly, installing the
      InfluxDB server on two nodes is not recommended to avoid split-brain
      situations in the Raft consensus of the InfluxDB cluster, as well as the
      *Pacemaker* cluster, which is responsible for the VIP address failover.
      It is possible to add or remove nodes with the
      :guilabel:`InfluxDB_Grafana` role in the cluster after deployment.

#. If required, adjust the disk partitioning as described in
   `Configure disk partitioning
   <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/configure-environment/customize-partitions.html>`_.

   By default, the InfluxDB-Grafana Plugin allocates:

     * 20% of the first available disk for the operating system by honoring
       a range of 15 GB minimum to 50 GB maximum.
     * 10 GB for ``/var/log``.
     * At least 30 GB for the InfluxDB database in ``/var/lib/influxdb``.

#. Deploy your environment as described in `Deploy an OpenStack environment
   <http://docs.openstack.org/developer/fuel-docs/userdocs/fuel-user-guide/deploy-environment.html>`_.
