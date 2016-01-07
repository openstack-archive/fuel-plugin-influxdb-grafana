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
# == Class: lma_monitoring_analytics::grafana_add_datasource

class lma_monitoring_analytics::grafana_add_datasource (
  $source_name = undef,
  $admin_username = undef,
  $admin_password = undef,
  $influxdb_username = undef,
  $influxdb_password = undef,
  $influxdb_database = undef,
  $domain = $lma_monitoring_analytics::params::grafana_domain,
  $http_port = $lma_monitoring_analytics::params::listen_port,
  $influxdb_url = $lma_monitoring_analytics::params::influxdb_url,
) inherits lma_monitoring_analytics::params {

  if ! $source_name {
    fail('source_name parameter is required')
  }

  grafana_datasource { $source_name:
    ensure           => present,
    url              => $influxdb_url,
    user             => $influxdb_username,
    password         => $influxdb_password,
    database         => $influxdb_database,
    access_mode      => 'proxy',
    is_default       => true,
    grafana_url      => "http://${domain}:${http_port}",
    grafana_user     => $admin_username,
    grafana_password => $admin_password,
    require          => Class['::grafana'],
  }
}
