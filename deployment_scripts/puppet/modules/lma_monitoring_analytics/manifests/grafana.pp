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
  $db_host,
  $db_name,
  $db_username,
  $db_password,
  $admin_username    = undef,
  $admin_password    = undef,
  $domain            = $lma_monitoring_analytics::params::grafana_domain,
  $http_port         = $lma_monitoring_analytics::params::listen_port,
  $influxdb_url      = $lma_monitoring_analytics::params::influxdb_url,
  $influxdb_username = undef,
  $influxdb_password = undef,
  $influxdb_database = undef,
) inherits lma_monitoring_analytics::params {

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

  $dashboard_defaults = {
    ensure           => present,
    grafana_url      => "http://${domain}:${http_port}",
    grafana_user     => $admin_username,
    grafana_password => $admin_password,
    require          => Class['::grafana'],
  }

  $dashboards = {
    'Main' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Main.json'),
    },
    'System' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/System.json'),
    },
    'LMA self-monitoring' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/LMA.json'),
    },
    'Apache' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Apache.json'),
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
    'Heat' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Heat.json'),
    },
    'Libvirt' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Libvirt.json'),
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
    'Memcached' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Memcached.json'),
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
    'Ceph' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Ceph.json'),
    },
    'Ceph OSD' => {
      content => template('lma_monitoring_analytics/grafana_dashboards/Ceph_OSD.json'),
    },
  }

  create_resources(grafana_dashboard, $dashboards, $dashboard_defaults)
}
