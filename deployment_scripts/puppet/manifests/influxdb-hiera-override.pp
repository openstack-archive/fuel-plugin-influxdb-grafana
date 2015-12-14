$hiera_dir = '/etc/hiera/override'
$plugin_name = 'influxdb_grafana'
$plugin_yaml = "${plugin_name}.yaml"
$vip_name = 'influxdb'

$network_metadata = hiera_hash('network_metadata')
if ! $network_metadata['vips'][$vip_name] {
  fail('InfluxDB VIP is not defined')
}

$database_vip = $network_metadata['vips'][$vip_name]['ipaddr']

$roles = [ $plugin_name ]
$influxdb_nodes = get_nodes_hash_by_roles($network_metadata, $roles)
$influxdb_address_map = get_node_to_ipaddr_map_by_network_role($influxdb_nodes, 'mgmt/influxdb_vip')
$inflxudb_nodes_ips = values($influxdb_address_map)
$influxdb_nodes_names = keys($influxdb_address_map)

$corosync_roles = [$plugin_name]
$corosync_nodes = $influx_nodes

###################
$calculated_content = inline_template('
corosync_roles:
<% require "yaml" -%>
<%
@corosync_roles.each do |crole|
%>  - <%= crole %>
<% end -%>
')

file {'/etc/hiera/override':
  ensure  => directory,
} ->
file { "${hiera_dir}/${plugin_yaml}":
  ensure  => file,
  content => "${calculated_content}\n",
}

package {'ruby-deep-merge':
  ensure  => 'installed',
}

file_line {"${plugin_name}_hiera_override":
  path  => '/etc/hiera.yaml',
  line  => "  - override/${plugin_name}",
  after => '  - override/module/%{calling_module}',
}
