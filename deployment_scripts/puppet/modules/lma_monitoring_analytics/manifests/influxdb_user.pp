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
# == Define: lma_monitoring_analytics::influxdb_user

define lma_monitoring_analytics::influxdb_user (
  $influxdb_url,
  $password,
  $username       = 'title',
  $admin_role     = false,
  $admin_user     = undef,
  $admin_password = undef,
) {

  include $lma_monitoring_analytics::params

  $create_user = $lma_monitoring_analytics::params::influxdb_create_user

  file { $create_user:
    owner   => 'root',
    group   => 'root',
    mode    => '0740',
    content => template('lma_monitoring_analytics/create_user.sh.erb'),
  }

  exec { 'create_user_script':
    command => $create_user,
    require => File[$create_user],
  }
}
