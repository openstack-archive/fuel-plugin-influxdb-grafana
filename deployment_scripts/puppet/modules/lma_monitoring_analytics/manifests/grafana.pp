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
  $ldap_enabled      = false,
  $ldap_parameters   = undef,
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

  $ldap_config       = '/etc/grafana/ldap.toml'

  class { '::grafana':
    install_method      => 'repo',
    version             => $version,
    manage_package_repo => false,
    cfg                 => {
      server      => {
        http_address => $http_address,
        http_port    => $http_port,
        domain       => $domain,
      },
      database    => {
        type     => 'mysql',
        host     => $full_db_host,
        name     => $db_name,
        user     => $db_username,
        password => $db_password,
      },
      'auth.ldap' => {
        enabled     => $ldap_enabled,
        config_file => $ldap_config,
      },
      security    => {
        admin_user     => $admin_username,
        admin_password => $admin_password,
      },
      analytics   => {
        reporting_enabled => false,
      },
    },
  }

  if $ldap_enabled {

    # Following parameters are used in ldap.toml.erb
    $ldap_servers               = $ldap_parameters['servers']
    $ldap_protocol              = $ldap_parameters['protocol']
    $ldap_server_port           = $ldap_parameters['port']
    $ldap_bind_dn               = $ldap_parameters['bind_dn']
    $ldap_bind_password         = $ldap_parameters['bind_password']
    $ldap_search_base_dn        = $ldap_parameters['search_base_dn']
    $ldap_search_filter         = $ldap_parameters['search_filter']
    $ldap_authorization_enabled = $ldap_parameters['authorization_enabled']
    $ldap_group_search_base_dns = $ldap_parameters['group_search_base_dns']
    $ldap_group_search_filter   = $ldap_parameters['group_search_filter']
    $ldap_admin_group_dn        = $ldap_parameters['admin_group_dn']
    $ldap_editor_group_dn       = $ldap_parameters['editor_group_dn']
    $ldap_viewer_group_dn       = $ldap_parameters['viewer_group_dn']

    file { $ldap_config:
      owner   => 'root',
      group   => 'grafana',
      mode    => '0660',
      content => template('lma_monitoring_analytics/ldap.toml.erb'),
      require => Class['::grafana']
    }
  }

  file { '/etc/logrotate.d/grafana.conf':
    ensure  => present,
    content => template('lma_monitoring_analytics/logrotate.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['::grafana'],
  }
}
