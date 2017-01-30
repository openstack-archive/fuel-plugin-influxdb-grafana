# Copyright 2016 Mirantis, Inc.
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

notice('fuel-plugin-influxdb-grafana: grafana_configuration.pp')

$deployment_id = hiera('deployment_id')
$master_ip = hiera('master_ip')
$influxdb_vip = hiera('lma::influxdb::vip')
$grafana_vip = hiera('lma::grafana::vip')
$influxdb_port = hiera('lma::influxdb::influxdb_port')
$grafana_link_created_file = '/var/cache/grafana_link_created_up_1.x'

$admin_username = hiera('lma::grafana::mysql::admin_username')
$admin_password = hiera('lma::grafana::mysql::admin_password')
$influxdb_username = hiera('lma::influxdb::username')
$influxdb_password = hiera('lma::influxdb::password')
$influxdb_database = hiera('lma::influxdb::dbname')

$lma_collector = hiera_hash('lma_collector', {})
$influxdb_mode = $lma_collector['influxdb_mode']
$import_influxdb = $influxdb_mode ? {
  'local' => true,
  default => false,
}

$elasticsearch_mode = $lma_collector['elasticsearch_mode']
$import_elasticsearch = $elasticsearch_mode ? {
  'local' => true,
  default => false,
}

if hiera('lma::grafana::tls::enabled') {
  $protocol = 'https'
  $grafana_hostname = hiera('lma::grafana::tls::hostname')
  $grafana_link_data = "{\"title\":\"Grafana\",\
  \"description\":\"Dashboard for visualizing metrics (${grafana_hostname}: ${protocol}://${grafana_vip})\",\
  \"url\":\"${protocol}://${grafana_hostname}/\"}"
} else {
  $protocol = 'http'
  $grafana_link_data = "{\"title\":\"Grafana\",\
  \"description\":\"Dashboard for visualizing metrics\",\
  \"url\":\"${protocol}://${grafana_vip}\"}"
}

grafana_datasource { 'lma':
  ensure           => present,
  url              => "http://${influxdb_vip}:${influxdb_port}",
  user             => $influxdb_username,
  password         => $influxdb_password,
  database         => $influxdb_database,
  access_mode      => 'proxy',
  is_default       => true,
  grafana_url      => "${protocol}://${grafana_vip}",
  grafana_user     => $admin_username,
  grafana_password => $admin_password,
}

class {'lma_monitoring_analytics::grafana_dashboards':
  admin_username       => $admin_username,
  admin_password       => $admin_password,
  protocol             => $protocol,
  host                 => $grafana_vip,
  port                 => hiera('lma::influxdb::grafana_frontend_port'),
  import_elasticsearch => $import_elasticsearch,
  import_influxdb      => $import_influxdb,
  require              => Grafana_datasource['lma'],
}

exec { 'notify_grafana_url':
  creates => $grafana_link_created_file,
  command => "/usr/bin/curl -sL -w \"%{http_code}\" \
-H 'Content-Type: application/json' -X POST -d '${grafana_link_data}' \
http://${master_ip}:8000/api/clusters/${deployment_id}/plugin_links \
-o /dev/null | /bin/grep 201 && touch ${grafana_link_created_file}",
  require => Class['lma_monitoring_analytics::grafana_dashboards'],
}
