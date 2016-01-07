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
#

$mgmt_vip = hiera('lma::influxdb::vip')
$influxdb_grafana = hiera('influxdb_grafana')

$admin_username = $influxdb_grafana['grafana_username']
$admin_password = $influxdb_grafana['grafana_userpass']
$influxdb_username = $influxdb_grafana['influxdb_username']
$influxdb_password = $influxdb_grafana['influxdb_userpass']
$influxdb_database = $influxdb_grafana['influxdb_dbname']

class {'lma_monitoring_analytics::grafana_add_datasource':
  source_name       => 'influxdb',
  admin_username    => $admin_username,
  admin_password    => $admin_password,
  influxdb_url      => "http://${mgmt_vip}:8086",
  influxdb_username => $influxdb_username,
  influxdb_password => $influxdb_password,
  influxdb_database => $influxdb_dbname,
  domain            => $mgmt_vip,
}
