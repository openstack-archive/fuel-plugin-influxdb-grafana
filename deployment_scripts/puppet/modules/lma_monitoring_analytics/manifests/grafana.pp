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
  $listen_port       = $lma_monitoring_analytics::params::listen_port,
  $influxdb_dbname   = undef,
  $influxdb_username = undef,
  $influxdb_userpass = undef,
) inherits lma_monitoring_analytics::params {

  $grafana_dir        = $lma_monitoring_analytics::params::grafana_dir
  $grafana_conf       = $lma_monitoring_analytics::params::grafana_conf
  $influxdb_host      = $lma_monitoring_analytics::params::influxdb_host
  $grafana_dbname     = $lma_monitoring_analytics::params::grafana_dbname
  $grafana_home_dashboard = $lma_monitoring_analytics::params::grafana_home_dashboard

  # Deploy sources
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

  # Install the dashboards
  $dashboard_defaults = {
    ensure           => present,
    storage_url      => "http://localhost:8086/db/${grafana_dbname}",
    storage_user     => $influxdb_username,
    storage_password => $influxdb_userpass,
  }
  $dashboards = {
    'Main' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Main.json'),
    },
    'Apache' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Apache.json'),
    },
    'Ceph' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Ceph.json'),
    },
    'Ceph OSD' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Ceph_OSD.json'),
    },
    'Cinder' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Cinder.json'),
    },
    'Glance' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Glance.json'),
    },
    'HAProxy' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/HAProxy.json'),
    },
    'Keystone' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Keystone.json'),
    },
    'Memcached' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Memcached.json'),
    },
    'MySQL' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/MySQL.json'),
    },
    'Neutron' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Neutron.json'),
    },
    'Nova' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Nova.json'),
    },
    'RabbitMQ' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/RabbitMQ.json'),
    },
    'System' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/System.json'),
    },
  }
  create_resources(grafana_dashboard, $dashboards, $dashboard_defaults)

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
