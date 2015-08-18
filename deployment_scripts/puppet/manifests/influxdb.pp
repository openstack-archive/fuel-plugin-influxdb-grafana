#    Copyright 2015 Mirantis, Inc.
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
#
$influxdb_grafana = hiera('influxdb_grafana')

if $influxdb_grafana['node_name'] == hiera('user_node_name') {
  # retention period value is expressd in days
  if $influxdb_grafana['retention_period'] == 0 {
    $retention_period = 'INF'
  } else {
    $retention_period = sprintf('%dd', $influxdb_grafana['retention_period'])
  }

  class { 'lma_monitoring_analytics::influxdb':
    influxdb_rootpass  => $influxdb_grafana['influxdb_rootpass'],
    influxdb_dbname    => $influxdb_grafana['influxdb_dbname'],
    influxdb_username  => $influxdb_grafana['influxdb_username'],
    influxdb_userpass  => $influxdb_grafana['influxdb_userpass'],
    influxdb_dir       => $influxdb_grafana['data_dir'],
    retention_period   => $retention_period,
    replication_factor => $influxdb_grafana['replication_factor'],
  }
}
