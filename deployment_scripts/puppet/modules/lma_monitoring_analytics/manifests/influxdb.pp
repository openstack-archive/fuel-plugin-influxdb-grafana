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
  $influxdb_dbname    = undef,
  $influxdb_username  = undef,
  $influxdb_userpass  = undef,
  $influxdb_rootpass  = undef,
  $influxdb_dir       = $lma_monitoring_analytics::params::influxdb_dir,
  $retention_period   = $lma_monitoring_analytics::params::influxdb_retention_period,
  $replication_factor = $lma_monitoring_analytics::params::influxdb_replication_factor,
  $raft_cluster       = undef,
) inherits lma_monitoring_analytics::params {

  $configure_influxdb = $lma_monitoring_analytics::params::influxdb_script
  if $retention_period == 0 {
    $real_retention_period = 'INF'
  } else {
    $real_retention_period = $retention_period
  }

  class { '::influxdb':
    data_dir     => "${influxdb_dir}/data",
    meta_dir     => "${influxdb_dir}/meta",
    hh_dir       => "${influxdb_dir}/hh",
    wal_dir      => "${influxdb_dir}/wal",
    raft_cluster => $raft_cluster,
  }

  file { $configure_influxdb:
    owner   => 'root',
    group   => 'root',
    mode    => '0740',
    content => template('lma_monitoring_analytics/configure_influxdb.sh.erb'),
  }

  exec { 'configure_influxdb_script':
    command => $configure_influxdb,
    require => [File[$configure_influxdb], Service['influxdb']],
  }
}
