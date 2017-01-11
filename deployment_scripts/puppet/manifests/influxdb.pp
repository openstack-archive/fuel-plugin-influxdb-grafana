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

notice('fuel-plugin-influxdb-grafana: influxdb.pp')

$data_directory = hiera('lma::influxdb::data_dir')
$wal_dir = "${data_directory}/wal"

# We set raft_nodes only for the non-primary node. The primary node will be
# started as the first node and it will be the leader of the Raft cluster.
if hiera('lma::influxdb::raft_leader') {
    $raft_nodes = undef
} else {
    $raft_nodes = hiera('lma::influxdb::raft_nodes')
}

user { 'influxdb':
  ensure => present,
  system => true,
  shell  => '/usr/sbin/nologin',
}

file { $data_directory:
  ensure  => 'directory',
  owner   => 'influxdb',
  group   => 'influxdb',
  require => User['influxdb'],
}

if hiera('lma::influxdb::wal::storage') == 'memory' {
  $wal_size = hiera('lma::influxdb::wal::size')
  file { $wal_dir:
    ensure  => directory,
    owner   => 'influxdb',
    group   => 'influxdb',
    require => File[$data_directory],
  }

  mount { $wal_dir:
    ensure   => mounted,
    device   => 'tmpfs',
    atboot   => true,
    options  => "size=${wal_size},rw",
    fstype   => 'tmpfs',
    remounts => false,
    before   => Class['lma_monitoring_analytics::influxdb'],
    require  => File[$wal_dir],
  }
}

# We cannot mix IP addresses and hostnames otherwise the Raft cluster won't
# start. We have to stick with IP addresses because hostnames map to the
# managament network space.
class { 'lma_monitoring_analytics::influxdb':
  base_directory => $data_directory,
  wal_dir        => $wal_dir,
  hostname       => hiera('lma::influxdb::listen_address'),
  version        => '1.1.1-1',
  require        => File[$data_directory],
}
