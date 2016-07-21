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