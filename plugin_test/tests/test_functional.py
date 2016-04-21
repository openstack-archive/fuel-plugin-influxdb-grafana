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

import base_test
import test_smoke_bvt


@test(groups=["plugins"])
class TestNodesInfluxdbPlugin(base_test.BaseTestInfluxdbPlugin):
    """Class for testing dynamic add/delete of nodes with
    the InfluxDB-Grafana plugin installed.
    """

    @test(depends_on=[
        test_smoke_bvt.TestInfluxdbPlugin.deploy_ha_influxdb_grafana_plugin],
        groups=["check_scaling_influxdb_grafana",
                "check_add_delete_controller_influxdb_grafana"])
    @log_snapshot_after_test
    def add_remove_controller_influxdb_grafana_plugin(self):
        """Verify that the number of controllers can scale up and down

        Scenario:
            1. Revert snapshot with 9 deployed nodes in HA configuration
            2. Remove one controller node
            3. Update the cluster
            4. Check that plugin is working
            5. Run OSTF
            6. Add one controller node (return previous state)
            7. Update the cluster
            8. Check that plugin is working
            9. Run OSTF

        Duration 120m
        """
        self.env.revert_snapshot("deploy_ha_influxdb_grafana_plugin")

        cluster_id = self.fuel_web.get_last_created_cluster()

        manipulated_node = {'slave-03': ['controller']}

        # Remove controller
        self.fuel_web.update_nodes(
            cluster_id,
            manipulated_node,
            pending_addition=False, pending_deletion=True,
        )

        # NOTE(rpromyshlennikov): We set "check_services=False" and
        # "should_fail=1" parameters in deploy_cluster_wait and run_ostf
        # methods because after removing one node
        # nova has been keeping it in service list
        self.fuel_web.deploy_cluster_wait(cluster_id, check_services=False)

        self.check_influxdb_plugin_online(cluster_id)

        self.fuel_web.run_ostf(cluster_id=cluster_id, should_fail=1)

        # Add controller
        self.fuel_web.update_nodes(
            cluster_id,
            manipulated_node,
        )

        self.fuel_web.deploy_cluster_wait(cluster_id, check_services=False)

        self.check_influxdb_plugin_online(cluster_id)

        self.fuel_web.run_ostf(cluster_id=cluster_id, should_fail=1)

        self.env.make_snapshot("add_remove_controller_influxdb_grafana_plugin")

    @test(depends_on=[
        test_smoke_bvt.TestInfluxdbPlugin.deploy_ha_influxdb_grafana_plugin],
        groups=["check_scaling_influxdb_grafana",
                "check_add_delete_compute_influxdb_grafana"])
    @log_snapshot_after_test
    def add_remove_compute_influxdb_grafana_plugin(self):
        """Verify that the number of computes can scale up and down

        Scenario:
            1. Revert snapshot with 9 deployed nodes in HA configuration
            2. Remove one compute node
            3. Update the cluster
            4. Check that plugin is working
            5. Run OSTF
            6. Add one compute node (return previous state)
            7. Update the cluster
            8. Check that plugin is working
            9. Run OSTF

        Duration 120m
        """
        self.env.revert_snapshot("deploy_ha_influxdb_grafana_plugin")

        cluster_id = self.fuel_web.get_last_created_cluster()

        manipulated_node = {'slave-04': ['compute', 'cinder']}

        # Remove compute
        self.fuel_web.update_nodes(
            cluster_id,
            manipulated_node,
            pending_addition=False, pending_deletion=True,
        )

        # NOTE(rpromyshlennikov): We set "check_services=False" and
        # "should_fail=1" parameters in deploy_cluster_wait and run_ostf
        # methods because after removing one node
        # nova has been keeping it in service list
        self.fuel_web.deploy_cluster_wait(cluster_id, check_services=False)

        self.check_influxdb_plugin_online(cluster_id)

        self.fuel_web.run_ostf(cluster_id=cluster_id, should_fail=1)

        # Add compute
        self.fuel_web.update_nodes(
            cluster_id,
            manipulated_node,
        )

        self.fuel_web.deploy_cluster_wait(cluster_id, check_services=False)

        self.check_influxdb_plugin_online(cluster_id)

        self.fuel_web.run_ostf(cluster_id=cluster_id, should_fail=1)

        self.env.make_snapshot("add_remove_compute_influxdb_grafana_plugin")

    @test(depends_on=[
        test_smoke_bvt.TestInfluxdbPlugin.deploy_ha_influxdb_grafana_plugin],
        groups=["check_scaling_influxdb_grafana",
                "check_add_delete_influxdb_grafana_node"])
    @log_snapshot_after_test
    def add_remove_node_with_influxdb_grafana_plugin(self):
        """Verify that the number of InfluxDB-Grafana nodes
        can scale up and down

        Scenario:
            1. Revert snapshot with 9 deployed nodes in HA configuration
            2. Remove one InfluxDB-Grafana node
            3. Update the cluster
            4. Check that plugin is working
            5. Run OSTF
            6. Add one InfluxDB-Grafana node (return previous state)
            7. Update the cluster
            8. Check that plugin is working
            9. Run OSTF

        Duration 120m
        """
        self.env.revert_snapshot("deploy_ha_influxdb_grafana_plugin")

        cluster_id = self.fuel_web.get_last_created_cluster()

        self.check_influxdb_nodes_count(cluster_id, 3)

        manipulated_node = {'slave-07': [self._role_name]}

        # Remove InfluxDB-Grafana node
        self.fuel_web.update_nodes(
            cluster_id,
            manipulated_node,
            pending_addition=False, pending_deletion=True,
        )

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.check_influxdb_plugin_online(cluster_id)

        self.check_influxdb_nodes_count(cluster_id, 2)

        self.fuel_web.run_ostf(cluster_id=cluster_id)

        # Add InfluxDB-Grafana node
        self.fuel_web.update_nodes(
            cluster_id,
            manipulated_node,
        )

        self.fuel_web.deploy_cluster_wait(cluster_id)

        self.check_influxdb_plugin_online(cluster_id)

        self.check_influxdb_nodes_count(cluster_id, 3)

        self.fuel_web.run_ostf(cluster_id=cluster_id)

        self.env.make_snapshot("add_remove_node_with_influxdb_grafana_plugin")

    @test(depends_on=[
        test_smoke_bvt.TestInfluxdbPlugin.deploy_ha_influxdb_grafana_plugin],
        groups=["check_failover_influxdb_grafana",
                "check_shutdown_influxdb_grafana_node"])
    @log_snapshot_after_test
    def shutdown_node_with_influxdb_grafana_plugin(self):
        """Verify that failover for InfluxDB cluster works.

        Scenario:
            1. Revert snapshot with 9 deployed nodes in HA configuration
            2. Connect to any influxdb_grafana node and run command:
               "crm status"
            3. Shutdown node were vip_influxdb was started
            4. Check that vip_influxdb was started on another node
            5. Check that plugin is working
            6. Check that no data lost after shutdown
            7. Run OSTF

        Duration 30m
        """
        self.env.revert_snapshot("deploy_ha_influxdb_grafana_plugin")

        cluster_id = self.fuel_web.get_last_created_cluster()

        master_node_hostname = (
            self.get_influxdb_master_node(cluster_id)['fqdn'])
        devops_master_node = self.fuel_web.get_devops_node_by_nailgun_fqdn(
            master_node_hostname)

        self.hard_shutdown_node(devops_master_node)

        self.wait_for_rotation_influx_master(cluster_id, master_node_hostname)

        self.check_influxdb_plugin_online(cluster_id)

        self.check_influxdb_nodes_count(cluster_id, 2)

        # TODO(rpromyshlennikov): check no data lost

        self.fuel_web.run_ostf(cluster_id=cluster_id)

        self.env.make_snapshot("shutdown_node_with_influxdb_grafana_plugin")
