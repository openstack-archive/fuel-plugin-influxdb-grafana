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
# == Class: lma_monitoring_analytics::influxdb

class lma_monitoring_analytics::influxdb (
  $base_directory = $lma_monitoring_analytics::params::influxdb_dir,
  $wal_dir        = undef,
  $hostname       = undef,
  $raft_nodes     = undef,
  $version        = undef,
) inherits lma_monitoring_analytics::params {

  if $raft_nodes {
    validate_array($raft_nodes)
  }

  if $wal_dir {
    $_wal_dir = $wal_dir
  } else {
    $_wal_dir = "${base_directory}/wal"
  }

  class { '::influxdb':
    data_dir   => "${base_directory}/data",
    meta_dir   => "${base_directory}/meta",
    hh_dir     => "${base_directory}/hh",
    wal_dir    => $_wal_dir,
    snapshot   => true,
    hostname   => $hostname,
    raft_nodes => $raft_nodes,
    version    => $version,
  }
}
