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
# == Class: lma_monitoring_analytics

class lma_monitoring_analytics (
  $listen_port       = $lma_monitoring_analytics::params::listen_port,
  $influxdb_dbname   = undef,
  $influxdb_username = undef,
  $influxdb_userpass = undef,
  $influxdb_rootpass = undef,
) inherits lma_monitoring_analytics::params {

  $grafana_dir        = $lma_monitoring_analytics::params::grafana_dir
  $grafana_conf       = $lma_monitoring_analytics::params::grafana_conf
  $influxdb_host      = $lma_monitoring_analytics::params::influxdb_host
  $configure_influxdb = $lma_monitoring_analytics::params::influxdb_script
  $grafana_dbname     = $lma_monitoring_analytics::params::grafana_dbname
  $grafana_home_dashboard = $lma_monitoring_analytics::params::grafana_home_dashboard

  # Configure InfluxDB:
  #   - update root password
  #   - create the user and db for metrics
  #   - create the db for grafana

  file { $configure_influxdb:
    owner   => 'root',
    group   => 'root',
    mode    => '0744',
    content => template('lma_monitoring_analytics/configure_influxdb.sh.erb'),
    notify  => Exec['configure_influxdb_script']
  }

  exec { 'configure_influxdb_script':
    command => $configure_influxdb,
  }

  # Deploy sources.
  file { $grafana_dir:
    source  => 'puppet:///modules/lma_monitoring_analytics/grafana/sources',
    recurse => true,
  }

  # Replace config.js
  file { $grafana_conf:
    ensure  => file,
    content => template('lma_monitoring_analytics/grafana/config.js.erb'),
    require => File[$grafana_dir],
  }

  # Install the dashboard
  grafana_dashboard { 'Logging, Monitoring and Alerting':
    ensure           => present,
    content          => template('lma_monitoring_analytics/grafana/main_dashboard.json'),
    storage_url      => "http://localhost:8086/db/${grafana_dbname}",
    storage_user     => $influxdb_username,
    storage_password => $influxdb_userpass,
    require          => Exec['configure_influxdb_script'],
  }

  # And now install nginx
  class { 'nginx':
    manage_repo           => false,
    nginx_vhosts          => {
      'grafana.local' => {
        'www_root' => $grafana_dir
      }
    },
    nginx_vhosts_defaults => {
      'listen_port'    => $listen_port,
      'listen_options' => 'default_server'
    },
    require               => File[$grafana_conf],
  }
}
