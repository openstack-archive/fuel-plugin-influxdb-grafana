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

$cluster_nodes = hiera('lma::influxdb::raft_nodes')
$stats_port    = '1000'
$influxdb_port = '8086'
$grafana_port  = '8000'

Openstack::Ha::Haproxy_service {
  balancermember_options => 'check',
  internal               => true,
  internal_virtual_ip    => hiera('lma::influxdb::vip'),
  public                 => false,
  public_virtual_ip      => undef,
  ipaddresses            => values($cluster_nodes),
  server_names           => keys($cluster_nodes),
}

openstack::ha::haproxy_service { 'influxdb':
  order                  => '800',
  listen_port            => $influxdb_port,
  balancermember_port    => $influxdb_port,
  haproxy_config_options => {
    'option'     => ['httpchk GET /ping HTTP/1.1'],
    'http-check' => 'expect status 204',
    'balance'    => 'roundrobin',
    'mode'       => 'http',
  },
}

# We use the load balancing algorithm called 'source' to ensure that the same
# client IP address will always reach the same server (as long as no server
# goes down or up). This is needed to support sticky session and to be able
# to authenticate.
openstack::ha::haproxy_service { 'grafana':
  order                  => '801',
  listen_port            => $grafana_port,
  balancermember_port    => $grafana_port,
  haproxy_config_options => {
    'balance' => 'source',
    'mode'    => 'http',
  },
}

openstack::ha::haproxy_service { 'stats':
  order                  => '010',
  listen_port            => $stats_port,
  server_names           => undef,
  haproxy_config_options => {
    'stats' => ['enable', 'uri /', 'refresh 5s', 'show-node',
                'show-legends', 'hide-version'],
    'mode'  => 'http',
  },
}
