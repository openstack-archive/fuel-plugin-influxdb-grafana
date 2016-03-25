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

class influxdb::install (
  $raft_nodes    = undef,
) {

  package { 'influxdb':
    ensure => installed,
  }

  if $raft_nodes {
    file { '/etc/default/influxdb':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('influxdb/influxdb_variables.erb')
    }
  }

  # Install cron job to rotate InfluxDB logs hourly basis
  # see LP #1561605
  $logrotate_conf = '/etc/logrotate_influxdb.conf'
  $log_file = '/var/log/influxdb/influxd.log'
  file { $logrotate_conf:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('influxdb/logrotate.conf.erb'),
    require => Package['influxdb'],
  }

  $logrotate_bin = '/usr/local/bin/logrotate_influxdb'
  file { $logrotate_bin:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('influxdb/logrotate.cron.erb'),
    require => File[$logrotate_conf],
  }

  cron { 'influxdb logrotate':
    ensure   => present,
    command  => $logrotate_bin,
    minute   => '*/30',
    hour     => '*',
    month    => '*',
    monthday => '*',
    require  => File[$logrotate_bin],
  }

}
