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

notice('StackLight: influxdb-grafana/hiera.pp')

$hiera_dir = '/etc/hiera/plugins'
$plugin_name = 'influxdb_grafana'
$plugin_yaml = "${plugin_name}.yaml"
$vip_name = 'influxdb'

$network_metadata = hiera_hash('network_metadata')
if ! $network_metadata['vips'][$vip_name] {
  fail('InfluxDB VIP is not defined')
}

$influxdb_leader = get_nodes_hash_by_roles($network_metadata, ["primary-${plugin_name}"])
$influxdb_others = get_nodes_hash_by_roles($network_metadata, [$plugin_name])
$influxdb_nodes = merge($influxdb_leader, $influxdb_others)
$influxdb_address_map = get_node_to_ipaddr_map_by_network_role($influxdb_nodes, 'influxdb_vip')

$influxdb_vip = $network_metadata['vips'][$vip_name]['ipaddr']

$corosync_roles = [$plugin_name, "primary-${plugin_name}"]


$calculated_content = inline_template('
---
lma::influxdb::raft_nodes: # The first node is the leader
    - <%= @influxdb_leader.keys.first %>
<% @influxdb_others.keys.sort.each do |k| -%>
    - <%= k %>
<% end -%>

lma::influxdb::backends:
<% @influxdb_address_map.keys.sort.each do |k| -%>
    <%= k %>: <%= @influxdb_address_map[k] %>
<% end -%>

lma::influxdb::vip: <%= @influxdb_vip %>

lma::corosync_roles:
<% @corosync_roles.sort.each do |crole| -%>
    - <%= crole %>
<% end -%>

')

file { "${hiera_dir}/${plugin_yaml}":
  ensure  => file,
  content => "${calculated_content}\n",
}
