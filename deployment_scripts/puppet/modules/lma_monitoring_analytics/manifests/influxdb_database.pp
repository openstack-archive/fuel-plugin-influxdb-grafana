#    Copyright 2016 Mirantis, Inc.
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
# == Define: lma_monitoring_analytics::influxdb_database

define lma_monitoring_analytics::influxdb_database (
  $admin_user,
  $admin_password,
  $influxdb_url,
  $db_user,
  $db_password,
  $db_name            = $title,
  $retention_period   = undef,
  $replication_factor = undef,
) {

  include lma_monitoring_analytics::params

  $create_db = $lma_monitoring_analytics::params::influxdb_create_database

  if ! $retention_period  {
    $real_retention_period = $lma_monitoring_analytics::params::influxdb_retention_period
  } else {
    # retention period value is expressd in days
    if $retention_period == 0 {
      $real_retention_period = 'INF'
    } else {
      $real_retention_period = sprintf('%dd', $retention_period)
    }
  }

  if ! $replication_factor {
    $real_replication_factor = $lma_monitoring_analytics::params::influxdb_replication_factor
  } else {
    $real_replication_factor = $replication_factor
  }

  file { $create_db:
    owner   => 'root',
    group   => 'root',
    mode    => '0740',
    content => template('lma_monitoring_analytics/create_db.sh.erb'),
  }

  exec { 'create_db_script':
    command => $create_db,
    require => File[$create_db],
  }

  file { 'remove_create_db':
    ensure => absent,
    name   => $create_db,
  }
}
