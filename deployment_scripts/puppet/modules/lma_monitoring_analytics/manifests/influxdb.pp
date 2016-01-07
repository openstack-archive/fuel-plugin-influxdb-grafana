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
  $rootpass      = undef,
  $dir           = $lma_monitoring_analytics::params::influxdb_dir,
  $raft_hostname = undef,
  $raft_nodes    = undef,
) inherits lma_monitoring_analytics::params {

  $set_admin_user = $lma_monitoring_analytics::params::influxdb_admin_script

  validate_array($raft_nodes)

  class { '::influxdb':
    data_dir      => "${dir}/data",
    meta_dir      => "${dir}/meta",
    hh_dir        => "${dir}/hh",
    wal_dir       => "${dir}/wal",
    raft_hostname => $raft_hostname,
    raft_nodes    => $raft_nodes,
  }

  if ! $rootpass {
    fail('Password for root user must be defined')
  }

  file { $set_admin_user:
    owner   => 'root',
    group   => 'root',
    mode    => '0740',
    content => template('lma_monitoring_analytics/set_admin_user.sh.erb'),
  }

  exec { 'set_admin_user_script':
    command => $set_admin_user,
    require => [File[$set_admin_user], Service['influxdb']],
  }
}
