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

#notice('MODULAR: influxdb_grafana/database_hiera_override.pp')
#
#$influxdb_grafana_plugin = hiera('influxdb_grafana', undef)
#$hiera_dir = '/etc/hiera/override'
#$plugin_name = 'influxdb_grafana'
#$plugin_yaml = "${plugin_name}.yaml"
#
#if $influxdb_grafana_plugin {
#  $network_metadata = hiera_hash('network_metadata')
#  if ! $network_metadata['vips']['influxdb'] {
#    fail('InfluxDB VIP is not defined')
#  }
#
#  $database_vip = $network_metadata['vips']['influxdb']['ipaddr']
#
#  #Set influxdb_nodes values
#  $influxdb_roles = [ 'influxdb_grafana' ]
#  $influxdb_nodes = get_nodes_hash_by_roles($network_metadata, $influxdb_roles)
#  $database_address_map = get_node_to_ipaddr_map_by_network_role($influxdb_nodes, 'mgmt/database')
#  $influxdb_nodes_ips = values($database_address_map)
#  $influxdb_nodes_names = keys($database_address_map)
#
#  #TODO(mattymo): debug needing corosync_roles
#  case hiera('role', 'none') {
#    /influxdb_grafana/: {
#      $corosync_roles = $influxdb_roles
#      $deploy_vrouter = false
#      $mysql_enabled  = true
#      $corosync_nodes = $influxdb_nodes
#    }
#    /controller/: {
#      $mysql_enabled = false
#    }
#    default: {
#    }
#  }
#  ###################
#  $calculated_content = inline_template('
#influxdb_vip: <%= @database_vip %>
#<% if @influxdb_nodes -%>
#<% require "yaml" -%>
#influxdb_nodes:
#<%= YAML.dump(@influxdb_nodes).sub(/--- *$/,"") %>
#<% end -%>
#<% if @corosync_nodes -%>
#<% require "yaml" -%>
#corosync_nodes:
#<%= YAML.dump(@corosync_nodes).sub(/--- *$/,"") %>
#<% end -%>
#<% if @corosync_roles -%>
#corosync_roles:
#<%
#@corosync_roles.each do |crole|
#%>  - <%= crole %>
#<% end -%>
#<% end -%>
#')
#
#  ###################
#  file {'/etc/hiera/override':
#    ensure  => directory,
#  } ->
#  file { "${hiera_dir}/${plugin_yaml}":
#    ensure  => file,
#    content => "${influxdb_grafana_plugin['yaml_additional_config']}\n${calculated_content}\n",
#  }
#
#  package {'ruby-deep-merge':
#    ensure  => 'installed',
#  }
#
#  file_line {"${plugin_name}_hiera_override":
#    path  => '/etc/hiera.yaml',
#    line  => "  - override/${plugin_name}",
#    after => '  - override/module/%{calling_module}',
#  }
#
#}
