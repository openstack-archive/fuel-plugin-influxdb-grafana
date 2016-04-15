# Copyright 2015 Mirantis, Inc.
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

notice('fuel-plugin-influxdb-grafana:influxdb.pp')

$influxdb_grafana = hiera('influxdb_grafana')
$directory = $influxdb_grafana['data_dir']

# We set raft_nodes only for non primary node. The primary node will be
# started as the first node and it will be the leader of the Raft cluster.
$current_roles = hiera('roles')
$is_primary = member($current_roles, 'primary-influxdb_grafana')

if $is_primary {
    $raft_nodes = undef
} else {
    $raft_nodes = hiera('lma::influxdb::raft_nodes')
}

user { 'influxdb':
  ensure => present,
  system => true,
  shell  => '/usr/sbin/nologin',
}

file { $directory:
  ensure  => 'directory',
  owner   => 'influxdb',
  group   => 'influxdb',
  require => User['influxdb'],
}

# We cannot mix IP addresses and hostnames otherwise the Raft cluster won't
# start. We decide to stick with hostnames because they are more meaningful.
class { 'lma_monitoring_analytics::influxdb':
  base_directory => $influxdb_grafana['data_dir'],
  hostname       => hiera('node_name'),
  raft_nodes     => $raft_nodes,
  require        => File[$directory],
}
