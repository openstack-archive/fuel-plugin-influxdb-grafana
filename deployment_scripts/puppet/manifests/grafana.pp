# Copyright 2015 Mirantis, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

notice('fuel-plugin-influxdb-grafana: grafana.pp')

$influxdb_grafana = hiera('influxdb_grafana')
$db_mode = $influxdb_grafana['mysql_mode']
$db_name = $influxdb_grafana['mysql_dbname']
$db_username = $influxdb_grafana['mysql_username']
$db_password = $influxdb_grafana['mysql_password']
$admin_username = $influxdb_grafana['grafana_username']
$admin_password = $influxdb_grafana['grafana_userpass']

case $db_mode {

  'local': {
    $db_host = join([hiera('database_vip'), '3306'], ':')
  }

  'remote': {
    $db_host = $influxdb_grafana['mysql_host']
  }

  default: {
    fail("'${db_mode}' database mode not supported for Grafana")
  }
}

class {'lma_monitoring_analytics::grafana':
  db_host        => $db_host,
  db_name        => $db_name,
  db_username    => $db_username,
  db_password    => $db_password,
  admin_username => $admin_username,
  admin_password => $admin_password,
  domain         => hiera('lma::influxdb::vip'),
  http_port      => hiera('lma::influxdb::grafana_port'),
  version        => '3.0.4-1464167696',
}
