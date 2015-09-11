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
# == Class: influxdb::params

class influxdb::service {
  include influxdb::params

  # Hack required for InfluxDB 0.9.3. The init script fails otherwise because
  # it tries to run shell commands with 'su' while the influxdb user has
  # /sbin/nologin as the shell
  file { $influxdb::params::run_directory:
    ensure => directory,
    owner  => $influxdb::params::influxdb_user,
    group  => $influxdb::params::influxdb_user,
  }

  file { "${influxdb::params::run_directory}/influxd.pid":
    ensure  => present,
    owner   => $influxdb::params::influxdb_user,
    group   => $influxdb::params::influxdb_user,
    before  => Service['influxdb'],
    require => File[$influxdb::params::run_directory],
  }

  service { 'influxdb':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    status     => '/usr/bin/pgrep -u influxdb -f "/opt/influxdb/influxd "'
  }
}
