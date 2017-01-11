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

notice('fuel-plugin-influxdb-grafana: haproxy.pp')

$influxdb_nodes_ips = hiera('lma::influxdb::raft_nodes')
$influxdb_nodes_names = prefix(range(1, size($influxdb_nodes_ips)), 'server_')
$influxdb_port = hiera('lma::influxdb::influxdb_port')
$grafana_nodes_ips = hiera('lma::grafana::nodes')
$grafana_nodes_names = prefix(range(1, size($grafana_nodes_ips)), 'server_')
$grafana_port  = hiera('lma::influxdb::grafana_port')
$grafana_frontend_port = hiera('lma::influxdb::grafana_frontend_port')
$influxdb_grafana = hiera_hash('influxdb_grafana')

Openstack::Ha::Haproxy_service {
  balancermember_options => 'check',
  internal               => true,
  public                 => false,
  public_virtual_ip      => undef,
}

openstack::ha::haproxy_service { 'influxdb':
  order                  => '800',
  internal_virtual_ip    => hiera('lma::influxdb::vip'),
  listen_port            => $influxdb_port,
  balancermember_port    => $influxdb_port,
  ipaddresses            => $influxdb_nodes_ips,
  server_names           => $influxdb_nodes_names,
  define_backups         => true,
  haproxy_config_options => {
    'option'     => ['httpchk GET /ping', 'httplog', 'dontlog-normal'],
    'http-check' => 'expect status 204',
    'balance'    => 'roundrobin',
    'mode'       => 'http',
  },
}

# We use the load balancing algorithm called 'source' to ensure that the same
# client IP address will always reach the same server (as long as no server
# goes down or up). This is needed to support sticky session and to be able
# to authenticate.
$grafana_haproxy_service = hiera('lma::grafana::haproxy_service')
if hiera('lma::grafana::tls::enabled') {
  openstack::ha::haproxy_service { $grafana_haproxy_service:
    order                  => '801',
    internal_virtual_ip    => hiera('lma::grafana::vip'),
    internal_ssl           => true,
    internal_ssl_path      => hiera('lma::grafana::tls::cert_file_path'),
    listen_port            => $grafana_frontend_port,
    balancermember_port    => $grafana_port,
    ipaddresses            => $grafana_nodes_ips,
    server_names           => $grafana_nodes_names,
    haproxy_config_options => {
      'option'  => ['httplog', 'dontlog-normal'],
      'balance' => 'source',
      'mode'    => 'http',
    },
  }
} else {
  openstack::ha::haproxy_service { $grafana_haproxy_service:
    order                  => '801',
    internal_virtual_ip    => hiera('lma::grafana::vip'),
    listen_port            => $grafana_frontend_port,
    balancermember_port    => $grafana_port,
    ipaddresses            => $grafana_nodes_ips,
    server_names           => $grafana_nodes_names,
    haproxy_config_options => {
      'option'  => ['httplog', 'dontlog-normal'],
      'balance' => 'source',
      'mode'    => 'http',
    },
  }
}
