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
#
# == Define: lma_monitoring_analytics::influxdb_user

define lma_monitoring_analytics::influxdb_user (
  $influxdb_url,
  $password,
  $admin_role     = false,
  $admin_user     = undef,
  $admin_password = undef,
) {

  $username = $title
  $create_user_script = "/tmp/create_user_${username}"

  file { $create_user_script:
    owner   => 'root',
    group   => 'root',
    mode    => '0740',
    content => template('lma_monitoring_analytics/create_user.sh.erb'),
  }

  exec { "run_${create_user_script}":
    command => $create_user_script,
    require => File[$create_user_script],
  }

  exec { "remove_${create_user_script}":
    command => "/bin/rm -f ${create_user_script}",
    require => Exec["run_${create_user_script}"],
  }
}
