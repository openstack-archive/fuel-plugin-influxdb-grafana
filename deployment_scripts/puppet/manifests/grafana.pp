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

prepare_network_config(hiera('network_scheme', {}))
$mgmt_address = get_network_role_property('management', 'ipaddr')
$influxdb_grafana = hiera('influxdb_grafana')

$lma_collector = hiera('lma_collector', {})
$elasticsearch_mode = $lma_collector['elasticsearch_mode']
$import_elasticsearch = $elasticsearch_mode ? {
  'local' => true,
  default => false,
}

class {'lma_monitoring_analytics::grafana':
  admin_username       => $influxdb_grafana['grafana_username'],
  admin_password       => $influxdb_grafana['grafana_userpass'],
  influxdb_username    => $influxdb_grafana['influxdb_username'],
  influxdb_password    => $influxdb_grafana['influxdb_userpass'],
  influxdb_database    => $influxdb_grafana['influxdb_dbname'],
  domain               => $mgmt_address,
  import_elasticsearch => $import_elasticsearch,
}
