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
  $admin_username    = undef,
  $admin_password    = undef,
  $http_port         = $lma_monitoring_analytics::params::listen_port,
  $influxdb_url      = $lma_monitoring_analytics::params::influxdb_url,
  $influxdb_username = undef,
  $influxdb_password = undef,
  $influxdb_database = undef,
) inherits lma_monitoring_analytics::params {

  class { '::grafana':
    install_method      => 'repo',
    manage_package_repo => false,
    cfg                 => {
      server    => {
        http_port => $http_port,
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
    password         => $admin_password,
    database         => $influxdb_database,
    access_mode      => 'proxy',
    is_default       => true,
    grafana_url      => "http://localhost:${http_port}",
    grafana_user     => $admin_username,
    grafana_password => $admin_password,
  }

  $dashboard_defaults = {
    ensure           => present,
    backend_url      => "http://localhost:${http_port}",
    backend_user     => $admin_username,
    backend_password => $admin_password,
    require          => Class['grafana'],
  }

  $dashboards = {
    'System' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/System.json'),
      tags    => [],
    },
  }
  create_resources(grafana_dashboard, $dashboards, $dashboard_defaults)
}
