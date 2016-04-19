#    Copyright 2016 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

from proboscis import test

from fuelweb_test.helpers.decorators import log_snapshot_after_test
from fuelweb_test.tests import base_test_case

import base_test


@test(groups=["plugins"])
class TestInfluxdbPlugin(base_test.BaseTestInfluxdbPlugin):
    """Class for smoke testing the InfluxDB-Grafana plugin."""

    @test(depends_on=[base_test_case.SetupEnvironment.prepare_slaves_3],
          groups=["install_influxdb_grafana"])
    @log_snapshot_after_test
    def install_influxdb_grafana_plugin(self):
        """Install InfluxDB-Grafana plugin and check it exists

        Scenario:
            1. Upload plugin to the master node
            2. Install plugin
            3. Create cluster
            4. Check that plugin exists

        Duration 20m
        """
        self.env.revert_snapshot("ready_with_3_slaves")

        self.prepare_plugin()

        cluster_id = self.create_cluster()

        self.activate_plugin(cluster_id)

    @test(depends_on=[base_test_case.SetupEnvironment.prepare_slaves_3],
          groups=["deploy_influxdb_grafana"])
    @log_snapshot_after_test
    def deploy_influxdb_grafana_plugin(self):
        """Deploy a cluster with the InfluxDB-Grafana plugin

        Scenario:
            1. Upload plugin to the master node
            2. Install plugin
            3. Create cluster
            4. Add 1 node with controller role
            5. Add 1 node with compute and cinder roles
            6. Add 1 node with influxdb_grafana role
            7. Deploy the cluster
            8. Check that plugin is working
            9. Run OSTF

        Duration 60m
        Snapshot deploy_influxdb_grafana_plugin
        """
        self.env.revert_snapshot("ready_with_3_slaves")

        self.prepare_plugin()

        cluster_id = self.create_cluster()

        self.activate_plugin(cluster_id)

        self.fuel_web.update_nodes(
            cluster_id,
            self.base_nodes,
        )

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.check_influxdb_plugin_online(cluster_id)

        self.fuel_web.run_ostf(cluster_id=cluster_id)

        self.env.make_snapshot("deploy_influxdb_grafana_plugin")

    @test(depends_on=[base_test_case.SetupEnvironment.prepare_slaves_9],
          groups=["deploy_ha_influxdb_grafana"])
    @log_snapshot_after_test
    def deploy_ha_influxdb_grafana_plugin(self):
        """Deploy a cluster with the InfluxDB-Grafana plugin in HA mode

        Scenario:
            1. Upload plugin to the master node
            2. Install plugin
            3. Create cluster
            4. Add 3 node with controller role
            5. Add 3 node with compute and cinder roles
            6. Add 3 node with influxdb_grafana role
            7. Deploy the cluster
            8. Check that plugin is working
            9. Run OSTF

        Duration 120m
        Snapshot deploy_ha_influxdb_grafana_plugin
        """
        self.check_run("deploy_ha_influxdb_grafana_plugin")
        self.env.revert_snapshot("ready_with_9_slaves")

        self.prepare_plugin()

        cluster_id = self.create_cluster()

        self.activate_plugin(cluster_id)

        self.fuel_web.update_nodes(
            cluster_id,
            self.full_ha_nodes,
        )

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.check_influxdb_plugin_online(cluster_id)

        self.fuel_web.run_ostf(cluster_id=cluster_id)

        self.env.make_snapshot("deploy_ha_influxdb_grafana_plugin",
                               is_make=True)
