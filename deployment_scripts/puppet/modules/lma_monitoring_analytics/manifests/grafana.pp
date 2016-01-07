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
# == Class: lma_monitoring_analytics::grafana

class lma_monitoring_analytics::grafana (
  $db_host           = undef,
  $db_name           = undef,
  $db_username       = undef,
  $db_password       = undef,
  $admin_username    = undef,
  $admin_password    = undef,
  $domain            = $lma_monitoring_analytics::params::grafana_domain,
  $http_port         = $lma_monitoring_analytics::params::listen_port,
  $influxdb_url      = $lma_monitoring_analytics::params::influxdb_url,
  $influxdb_username = undef,
  $influxdb_password = undef,
  $influxdb_database = undef,
) inherits lma_monitoring_analytics::params {

  if ! $db_host {
    fail('db_host parameter is required')
  }

  if ! $db_name {
    fail('db_name parameter is required')
  }

  if ! $db_username {
    fail('db_username parameter is required')
  }

  if ! $db_password {
    fail('db_password parameter is required')
  }

  validate_string($db_host)
  validate_string($db_name)
  validate_string($db_username)
  validate_string($db_password)

  # If no port is specified Grafana will not start. So we check if the
  # variable contains a port value and if not, we add ':3306'.
  if $db_host =~ /:[0-9]+$/ {
    $full_db_host = $db_host
  } else {
    $full_db_host = "${db_host}:3306"
  }

  class { '::grafana':
    install_method      => 'repo',
    version             => latest,
    manage_package_repo => false,
    cfg                 => {
      server    => {
        http_port => $http_port,
        domain    => $domain,
      },
      database  => {
        type     => 'mysql',
        host     => $full_db_host,
        name     => $db_name,
        user     => $db_username,
        password => $db_password,
      },
      security  => {
        admin_user     => $admin_username,
        admin_password => $admin_password,
      },
      analytics => {
        reporting_enabled => false,
      },
    },
  }

  grafana_datasource { 'influxdb':
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
