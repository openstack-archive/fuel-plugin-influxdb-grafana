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
# == Class: influxdb::install

class influxdb::install {

  package { 'influxdb':
    ensure => installed,
  }

  # The init script shipped by InfluxDB 0.9.4 fails because it tries to create
  # the PID file using 'su' without specifying /bin/sh while the influxdb user
  # has /sbin/nologin as the shell.
  file { '/etc/init.d/influxdb':
    ensure  => present,
    source  => 'puppet:///modules/influxdb/init.sh',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['influxdb'],
  }

  # Ensure rolling upgrade (see LP #1535440)
  file { '/etc/logrotate.d/influxdb':
    ensure => absent,
  }
  # Fix the wrong permission set by the influxdb package
  file { '/etc/logrotate.d/influxd':
    ensure  => present,
    mode    => '644',
    require => Package['influxdb'],
  }
}
