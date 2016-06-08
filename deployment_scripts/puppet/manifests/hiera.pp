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

notice('fuel-plugin-influxdb-grafana: hiera.pp')

# Initialize network-related variables
$network_scheme   = hiera_hash('network_scheme')
$network_metadata = hiera_hash('network_metadata')
prepare_network_config($network_scheme)

$influxdb_grafana = hiera('influxdb_grafana')
$hiera_file = '/etc/hiera/plugins/influxdb_grafana.yaml'
$listen_address = get_network_role_property('influxdb_vip', 'ipaddr')
$vip_name = 'influxdb'
if ! $network_metadata['vips'][$vip_name] {
  fail('InfluxDB VIP is not defined')
}
$influxdb_vip = $network_metadata['vips'][$vip_name]['ipaddr']

$influxdb_leader = get_nodes_hash_by_roles($network_metadata, ['primary-influxdb_grafana'])
$leader_ip_addresses = values(get_node_to_ipaddr_map_by_network_role($influxdb_leader, 'influxdb_vip'))
$leader_ip_address = $leader_ip_addresses[0]

$influxdb_others = get_nodes_hash_by_roles($network_metadata, ['influxdb_grafana'])
$others_ip_addresses = sort(values(get_node_to_ipaddr_map_by_network_role($influxdb_others, 'influxdb_vip')))

$tls_enabled = $influxdb_grafana['tls_enabled']
if $tls_enabled {
  $grafana_hostname = $influxdb_grafana['grafana_hostname']
  $cert_dir = '/etc/haproxy/certs'
  $cert_file = "${cert_dir}/${influxdb_grafana['grafana_ssl_cert']['name']}"

  file { $cert_dir:
    ensure => directory,
    mode   => '0700'
  }

  file { $cert_file:
    ensure  => present,
    content => $influxdb_grafana['grafana_ssl_cert']['content'],
    require => File[$cert_dir]
  }
}

$calculated_content = inline_template('
---
lma::influxdb::data_dir: "/var/lib/influxdb"
lma::influxdb::listen_address: "<%= @listen_address %>"
lma::influxdb::influxdb_port: 8086
lma::influxdb::grafana_port: 8000
lma::influxdb::raft_leader: <%= @leader_ip_address == @listen_address ? "true" : "false" %>
lma::influxdb::raft_nodes: # The first node is the leader
    - "<%= @leader_ip_address %>"
<% @others_ip_addresses.each do |x| -%>
    - "<%= x %>"
<% end -%>
lma::influxdb::vip: <%= @influxdb_vip %>
lma::corosync_roles:
    - primary-influxdb_grafana
    - influxdb_grafana

lma::grafana::tls_enabled: <%= @tls_enabled %>
<% if @tls_enabled -%>
lma::grafana::hostname: "<%= @grafana_hostname %>"
lma::grafana::cert_file: "<%= @cert_file %>"
<% end -%>
')

file { $hiera_file:
  ensure  => file,
  mode    => '0440',
  content => $calculated_content,
}
