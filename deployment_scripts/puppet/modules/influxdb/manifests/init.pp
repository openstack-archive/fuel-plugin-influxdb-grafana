#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
# == Class: influxdb

class influxdb (
  $data_dir   = $influxdb::params::data_dir,
  $hh_dir     = $influxdb::params::hh_dir,
  $meta_dir   = $influxdb::params::meta_dir,
  $wal_dir    = $influxdb::params::wal_dir,
  $snapshot   = $influxdb::params::snapshot,
  $version    = undef,
  $hostname   = undef,
  $raft_nodes = undef,
) inherits influxdb::params {

  if $version {
    $use_version = $version
  } else {
    $use_version = 'latest'
  }

  class {'influxdb::install':
    raft_nodes => $raft_nodes,
    version    => $use_version,
  }

  class {'influxdb::service':
    require => Class['influxdb::install'],
  }

  class {'influxdb::configure':
    hostname     => $hostname,
    auth_enabled => $influxdb::params::auth_enabled,
    config_file  => $influxdb::params::config_file,
    data_dir     => $data_dir,
    hh_dir       => $hh_dir,
    meta_dir     => $meta_dir,
    wal_dir      => $wal_dir,
    snapshot     => $snapshot,
    notify       => Class['influxdb::service'],
  }
}
