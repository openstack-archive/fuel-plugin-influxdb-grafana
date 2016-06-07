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
# == Class: lma_monitoring_analytics::grafana

class lma_monitoring_analytics::grafana (
  $db_host,
  $db_name,
  $db_username,
  $db_password,
  $admin_username    = undef,
  $admin_password    = undef,
  $domain            = $lma_monitoring_analytics::params::grafana_domain,
  $http_address      = $lma_monitoring_analytics::params::grafana_address,
  $http_port         = $lma_monitoring_analytics::params::grafana_port,
  $version           = 'latest',
) inherits lma_monitoring_analytics::params {

  validate_string($db_host)
  validate_string($db_name)
  validate_string($db_username)
  validate_string($db_password)
  validate_string($http_address)

  # If no port is specified Grafana will not start. So we check if the
  # variable contains a port value and if not, we add ':3306'.
  if $db_host =~ /:[0-9]+$/ {
    $full_db_host = $db_host
  } else {
    $full_db_host = "${db_host}:3306"
  }

  # The user and group are provisioned before creating the log directory, this
  # works because the Grafana package uses by default the same user=grafana and
  # group=grafana.
  # Drawback: if somebody modifies the user/group used to launch Grafana
  # (eg by updating the init script manually), unfortunatly Grafana won't be
  # able to log. This is due a lack of the grafana module which doesn't
  # provide ability to configure init script variables.
  user { 'grafana':
    ensure => present,
  }
  group { 'grafana':
    ensure => present,
  }

  # Assume that /var/log already exists
  $log_dir = '/var/log/grafana'
  file { $log_dir:
    ensure  => 'directory',
    owner   => 'grafana',
    group   => 'grafana',
    mode    => '0655',
    require => [User['grafana'], Group['grafana']],
  }

  class { '::grafana':
    install_method      => 'repo',
    version             => $version,
    manage_package_repo => false,
    cfg                 => {
      paths     => {
        logs => $log_dir,
      },
      server    => {
        http_address => $http_address,
        http_port    => $http_port,
        domain       => $domain,
      },
      database  => {
        type     => 'mysql',
        host     => $full_db_host,
        name     => $db_name,
        user     => $db_username,
        password => $db_password,
      },
      security  => {
        admin_user     => $admin_username,
        admin_password => $admin_password,
      },
      analytics => {
        reporting_enabled => false,
      },
    },
    require             => File[$log_dir],
  }

  # The following template used $log_dir variable.
  $logrotate_conf = '/etc/logrotate.d/grafana.conf'
  file { $logrotate_conf:
    ensure  => present,
    content => template('lma_monitoring_analytics/logrotate.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['::grafana'],
  }
}
