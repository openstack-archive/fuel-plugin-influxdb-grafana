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
import os

from proboscis import asserts
import requests

from fuelweb_test import logger
from fuelweb_test import settings
from fuelweb_test.tests import base_test_case


class BaseTestInfluxdbPlugin(base_test_case.TestBasic):
    """Common test class to operate with InfluxDB-Grafana plugin."""
    _name = 'influxdb_grafana'
    _version = '0.9.0'
    _role_name = 'influxdb_grafana'

    _influxdb_db_name = "lma"
    _influxdb_user = 'influxdb'
    _influxdb_pass = 'influxdbpass'
    _influxdb_rootuser = 'root'
    _influxdb_rootpass = 'r00tme'
    _influxdb_url = "http://{0}:8086/query"

    _grafana_user = 'grafana'
    _grafana_pass = 'grafanapass'
    _grafana_url = "http://{0}:{1}@{2}:8000/api/org"

    _mysql_mode = 'local'
    _mysql_dbname = 'grafanalma'
    _mysql_user = 'grafanalma'
    _mysql_pass = 'mysqlpass'

    @property
    def base_nodes(self):
        base_nodes = {
            'slave-01': ['controller'],
            'slave-02': ['compute', 'cinder'],
            'slave-03': [self._role_name],
        }
        return base_nodes

    @property
    def full_ha_nodes(self):
        full_ha_nodes = {
            'slave-01': ['controller'],
            'slave-02': ['controller'],
            'slave-03': ['controller'],
            'slave-04': ['compute', 'cinder'],
            'slave-05': ['compute', 'cinder'],
            'slave-06': ['compute', 'cinder'],
            'slave-07': [self._role_name],
            'slave-08': [self._role_name],
            'slave-09': [self._role_name],
        }
        return full_ha_nodes

    def get_vip(self, cluster_id):
        networks = self.fuel_web.client.get_networks(cluster_id)
        influxdb_vip = networks.get('vips').get('influxdb', {}).get(
            'ipaddr', None)
        asserts.assert_is_not_none(influxdb_vip,
                                   "Failed to get the IP of InfluxDB server")

        logger.debug("Check that InfluxDB is ready")
        return influxdb_vip

    def create_cluster(self, settings=None, mode=settings.DEPLOYMENT_MODE):
        cluster_id = self.fuel_web.create_cluster(
            name=self.__class__.__name__,
            settings=settings,
            mode=mode,
        )
        return cluster_id

    def prepare_plugin(self):
        self.env.admin_actions.upload_plugin(
            plugin=settings.INFLUXDB_GRAFANA_PLUGIN_PATH)
        self.env.admin_actions.install_plugin(
            plugin_file_name=os.path.basename(
                settings.INFLUXDB_GRAFANA_PLUGIN_PATH))

    def activate_plugin(self, cluster_id):
        msg = "Plugin couldn't be enabled. Check plugin version. Test aborted"
        asserts.assert_true(
            self.fuel_web.check_plugin_exists(cluster_id, self._name),
            msg)

        options = {
            'influxdb_rootpass/value': self._influxdb_rootpass,
            'influxdb_username/value': self._influxdb_user,
            'influxdb_userpass/value': self._influxdb_pass,
            'grafana_username/value': self._grafana_user,
            'grafana_userpass/value': self._grafana_pass,
            'mysql_mode/value': self._mysql_mode,
            'mysql_dbname/value': self._mysql_dbname,
            'mysql_username/value': self._mysql_user,
            'mysql_password/value': self._mysql_pass,
        }

        self.fuel_web.update_plugin_settings(cluster_id, self._name,
                                             self._version, options)

    def make_request_to_influx(self, cluster_id,
                               db=_influxdb_db_name,
                               user=_influxdb_rootuser,
                               password=_influxdb_rootpass,
                               query="",
                               expected_code=200):
        influxdb_vip = self.get_vip(cluster_id)
        params = {
            "db": db,
            "u": user,
            "p": password,
            "q": query,
        }
        r = requests.get(self._influxdb_url.format(influxdb_vip),
                         params=params)
        msg = "InfluxDB responded with {0}, expected {1}".format(r.status_code,
                                                                 expected_code)
        asserts.assert_equal(r.status_code, expected_code, msg)
        return r

    def check_influxdb_plugin_online(self, cluster_id):
        self.make_request_to_influx(cluster_id,
                                    query="show measurements")

        logger.debug("Check that the Grafana server is running")

        r = requests.get(self._grafana_url.format(
            self._grafana_user, self._grafana_pass, self.get_vip(cluster_id)))
        msg = "Grafana server responded with {}, expected 200".format(
            r.status_code)
        asserts.assert_equal(r.status_code, 200, msg)

    def check_influxdb_nodes_count(self, cluster_id, nodes_count=1):
        response = self.make_request_to_influx(
            cluster_id,
            user=self._influxdb_rootuser,
            password=self._influxdb_rootpass,
            query="show servers")

        nodes_count_responsed = len(
            response.json()["results"][0]["series"][0]["values"])

        msg = "InfluxDB nodes count expected, received instead: {}".format(
            nodes_count_responsed)
        asserts.assert_equal(nodes_count, nodes_count_responsed, msg)
