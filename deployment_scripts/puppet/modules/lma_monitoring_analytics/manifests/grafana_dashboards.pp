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
#
# == Class: lma_monitoring_analytics::grafana_dashboards

class lma_monitoring_analytics::grafana_dashboards (
  $admin_username,
  $admin_password,
  $host = $lma_monitoring_analytics::params::grafana_domain,
  $port = $lma_monitoring_analytics::params::listen_port,
) inherits lma_monitoring_analytics::params {

  $dashboard_defaults = {
    ensure           => present,
    grafana_url      => "http://${host}:${port}",
    grafana_user     => $admin_username,
    grafana_password => $admin_password,
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
