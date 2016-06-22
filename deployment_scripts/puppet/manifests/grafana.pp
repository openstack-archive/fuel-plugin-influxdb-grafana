# Copyright 2015 Mirantis, Inc.
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

notice('fuel-plugin-influxdb-grafana: grafana.pp')

$db_mode = hiera('lma::grafana::mysql::mode')
case $db_mode {

  'local': {
    $db_host = join([hiera('database_vip'), '3306'], ':')
  }

  'remote': {
    $db_host = hiera('lma::grafana::mysql::host')
  }

  default: {
    fail("'${db_mode}' database mode not supported for Grafana")
  }
}

$ldap_enabled = hiera('lma::grafana::ldap::enabled')
if $ldap_enabled {
  $ldap_parameters = {
    servers               => hiera('lma::grafana::ldap::servers'),
    protocol              => hiera('lma::grafana::ldap::protocol'),
    port                  => hiera('lma::grafana::ldap::port'),
    bind_dn               => hiera('lma::grafana::ldap::bind_dn'),
    bind_password         => hiera('lma::grafana::ldap::bind_password'),
    search_base_dns       => hiera('lma::grafana::ldap::user_search_base_dns'),
    search_filter         => hiera('lma::grafana::ldap::user_search_filter'),
    authorization_enabled => hiera('lma::grafana::ldap::authorization_enabled'),
    group_search_base_dns => hiera('lma::grafana::ldap::group_search_base_dns'),
    group_search_filter   => hiera('lma::grafana::ldap::group_search_filter'),
    admin_group_dn        => hiera('lma::grafana::ldap::admin_group_dn', ''),
    viewer_group_dn       => hiera('lma::grafana::ldap::viewer_group_dn', ''),
  }
} else {
  $ldap_parameters = undef
}

class {'lma_monitoring_analytics::grafana':
  db_host        => $db_host,
  db_name        => hiera('lma::grafana::mysql::dbname'),
  db_username    => hiera('lma::grafana::mysql::username'),
  db_password    => hiera('lma::grafana::mysql::password'),
  admin_username => hiera('lma::grafana::mysql::admin_username'),
  admin_password => hiera('lma::grafana::mysql::admin_userpass'),
  domain         => hiera('lma::influxdb::vip'),
  http_port      => hiera('lma::influxdb::grafana_port'),
  version        => '3.0.4-1464167696',
}
