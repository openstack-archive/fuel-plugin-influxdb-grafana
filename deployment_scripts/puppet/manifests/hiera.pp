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

if $::operatingsystem == 'Ubuntu' and $::operatingsystemrelease == '14.04' {
  # This is required to install the InfluxDB package on Trusty machines that
  # have systemd installed. The systemctl-shim package will force the removal
  # of the systemd package.
  # See https://bugs.launchpad.net/lma-toolchain/+bug/1652640 for details
  package { 'systemd-shim':
    ensure => present,
  }
}

$fuel_version = 0 + hiera('fuel_version')

# Initialize network-related variables
$network_scheme   = hiera_hash('network_scheme')
$network_metadata = hiera_hash('network_metadata')
prepare_network_config($network_scheme)

$influxdb_grafana = hiera('influxdb_grafana')
$hiera_file = '/etc/hiera/plugins/influxdb_grafana.yaml'
$influxdb_listen_address = get_network_role_property('influxdb_vip', 'ipaddr')
if ! $network_metadata['vips']['influxdb'] {
  fail('InfluxDB VIP is not defined')
}
$influxdb_vip = $network_metadata['vips']['influxdb']['ipaddr']

$influxdb_leader = get_nodes_hash_by_roles($network_metadata, ['primary-influxdb_grafana'])
$leader_ip_addresses = values(get_node_to_ipaddr_map_by_network_role($influxdb_leader, 'influxdb_vip'))
$leader_ip_address = $leader_ip_addresses[0]

$influxdb_others = get_nodes_hash_by_roles($network_metadata, ['influxdb_grafana'])
$others_ip_addresses = sort(values(get_node_to_ipaddr_map_by_network_role($influxdb_others, 'influxdb_vip')))

# For security reasons (eg not exposing Grafana on the public network), only
# the Grafana VIP should listen on the 'grafana' network and the Grafana
# services themselves should listen on the 'influxdb_vip' network which is an
# equivalent of the management network for OpenStack.
$grafana_listen_address = $influxdb_listen_address
$grafana_ip_addresses = concat([$leader_ip_address], $others_ip_addresses)
if ! $network_metadata['vips']['grafana'] {
  fail('Grafana VIP is not defined')
}
$grafana_vip = $network_metadata['vips']['grafana']['ipaddr']

$influxdb_admin_password = $influxdb_grafana['influxdb_rootpass']
$influxdb_username = $influxdb_grafana['influxdb_username']
$influxdb_password = $influxdb_grafana['influxdb_userpass']
$influxdb_dbname   = $influxdb_grafana['influxdb_dbname']

$retention_period = $influxdb_grafana['retention_period']
if $influxdb_grafana['influxdb_in_memory_wal'] {
  $influxdb_wal_storage = 'memory'
  # Allocate 10% of the total RAM for the WAL partition (but no more than 4GB)
  $influxdb_wal_size = min(4 * 1024 * 1024 * 1024, $::memorysize_mb * 1024 * 1024 * 0.1)
} else {
  $influxdb_wal_storage = 'disk'
  $influxdb_wal_size = 0
}

# Parameters related to MySQL
$host = $influxdb_grafana['mysql_host']
$db_mode = $influxdb_grafana['mysql_mode']
$db_name = $influxdb_grafana['mysql_dbname']
$db_username = $influxdb_grafana['mysql_username']
$db_password = $influxdb_grafana['mysql_password']
$admin_username = $influxdb_grafana['grafana_username']
$admin_password = $influxdb_grafana['grafana_userpass']

$tls_enabled = $influxdb_grafana['tls_enabled']
if $tls_enabled {
  $grafana_hostname = $influxdb_grafana['grafana_hostname']
  $cert_base_dir = '/etc/haproxy'
  $cert_dir = "${cert_base_dir}/certs"
  $cert_file_path = "${cert_dir}/${influxdb_grafana['grafana_ssl_cert']['name']}"

  file { $cert_base_dir:
    ensure => directory,
    mode   => '0755'
  }

  file { $cert_dir:
    ensure  => directory,
    mode    => '0700',
    require => File[$cert_base_dir]
  }

  file { $cert_file_path:
    ensure  => present,
    mode    => '0400',
    content => $influxdb_grafana['grafana_ssl_cert']['content'],
    require => File[$cert_dir]
  }
}

$ldap_enabled               = $influxdb_grafana['ldap_enabled']
$ldap_protocol              = $influxdb_grafana['ldap_protocol_for_grafana']
$ldap_servers               = $influxdb_grafana['ldap_servers']
$ldap_bind_dn               = $influxdb_grafana['ldap_bind_dn']
$ldap_bind_password         = $influxdb_grafana['ldap_bind_password']
$ldap_user_search_base_dns  = $influxdb_grafana['ldap_user_search_base_dns']
$ldap_user_search_filter    = $influxdb_grafana['ldap_user_search_filter']
$ldap_authorization_enabled = $influxdb_grafana['ldap_authorization_enabled']
$ldap_group_search_base_dns = $influxdb_grafana['ldap_group_search_base_dns']
$ldap_group_search_filter   = $influxdb_grafana['ldap_group_search_filter']
$ldap_admin_group_dn        = $influxdb_grafana['ldap_admin_group_dn']
$ldap_viewer_group_dn       = $influxdb_grafana['ldap_viewer_group_dn']

if ! $influxdb_grafana['ldap_server_port'] {
  if downcase($ldap_protocol) == 'ldap' {
    $ldap_port = 389
  } else {
    $ldap_port = 636
  }
} else {
  $ldap_port = $influxdb_grafana['ldap_server_port']
}

$calculated_content = inline_template('
---
lma::influxdb::data_dir: "/var/lib/influxdb"
lma::influxdb::listen_address: "<%= @influxdb_listen_address %>"
lma::influxdb::influxdb_port: 8086
lma::influxdb::grafana_port: 8000
<% if @tls_enabled -%>
lma::influxdb::grafana_frontend_port: 443
<% else -%>
lma::influxdb::grafana_frontend_port: 80
<% end -%>
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

# The replication factor is always 3 to support scaling up the cluster
# from 1 or 2 nodes to 3 nodes.
lma::influxdb::replication_factor: 3
lma::influxdb::retention_period: <%= @retention_period %>
lma::influxdb::wal::storage: <%= @influxdb_wal_storage %>
lma::influxdb::wal::size: <%= @influxdb_wal_size.to_i %>

lma::influxdb::admin_username: "root"
lma::influxdb::admin_password: >-
    <%= @influxdb_admin_password %>
lma::influxdb::username: >-
  <%= @influxdb_username %>
# InfluxDB password must be a string representation, see bug/1634461
lma::influxdb::password: >-
    <%= @influxdb_password %>
lma::influxdb::dbname: <%= @influxdb_dbname %>

lma::grafana::listen_address: "<%= @grafana_listen_address %>"
lma::grafana::vip: <%= @grafana_vip %>
lma::grafana::nodes:
<% @grafana_ip_addresses.each do |x| -%>
    - "<%= x %>"
<% end -%>

lma::grafana::mysql::host: <%= @host %>
lma::grafana::mysql::mode: <%= @db_mode %>
lma::grafana::mysql::dbname: <%= @db_name %>
lma::grafana::mysql::username: >-
  <%= @db_username %>
# MySQL password must be a string representation, see bug/1596438
lma::grafana::mysql::password: >-
    <%= @db_password %>
lma::grafana::mysql::admin_username: >-
  <%= @admin_username %>
lma::grafana::mysql::admin_password: >-
    <%= @admin_password %>

lma::grafana::haproxy_service: grafana
lma::grafana::tls::enabled: <%= @tls_enabled %>
<% if @tls_enabled -%>
lma::grafana::tls::hostname: "<%= @grafana_hostname %>"
lma::grafana::tls::cert_file_path: "<%= @cert_file_path %>"
<% end -%>

lma::grafana::ldap::enabled: <%= @ldap_enabled %>
lma::grafana::ldap::authorization_enabled: <%= @ldap_authorization_enabled %>
<% if @ldap_enabled -%>
lma::grafana::ldap::servers: <%= @ldap_servers %>
lma::grafana::ldap::protocol: <%= @ldap_protocol %>
lma::grafana::ldap::port: <%= @ldap_port %>
lma::grafana::ldap::bind_dn: >-
  <%= @ldap_bind_dn %>
lma::grafana::ldap::bind_password: >-
    <%= @ldap_bind_password %>
lma::grafana::ldap::user_search_base_dns: >-
  <%= @ldap_user_search_base_dns %>
lma::grafana::ldap::user_search_filter: >-
  <%= @ldap_user_search_filter %>
lma::grafana::ldap::group_search_base_dns: >-
  <%= @ldap_group_search_base_dns %>
lma::grafana::ldap::group_search_filter: >-
  <%= @ldap_group_search_filter %>
<% if @ldap_authorization_enabled -%>
lma::grafana::ldap::admin_group_dn: >-
  <%= @ldap_admin_group_dn %>
lma::grafana::ldap::viewer_group_dn: >-
  <%= @ldap_viewer_group_dn %>
<% end -%>
<% end -%>
')

file { $hiera_file:
  ensure  => file,
  content => $calculated_content,
}

if $fuel_version >= 9.0 {
  class { '::osnailyfacter::netconfig::hiera_default_route' :}
}
