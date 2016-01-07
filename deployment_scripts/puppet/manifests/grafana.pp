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

prepare_network_config(hiera('network_scheme', {}))
$mgmt_vip = hiera('lma::influxdb::vip')
$influxdb_grafana = hiera('influxdb_grafana')

$db_mode = $influxdb_grafana['mysql_mode']
$db_name = $influxdb_grafana['mysql_dbname']
$db_username = $influxdb_grafana['mysql_username']
$db_password = $influxdb_grafana['mysql_password']

$admin_username = $influxdb_grafana['grafana_username']
$admin_password = $influxdb_grafana['grafana_userpass']

case $db_mode {

  'local': {
    $mysql  = hiera('mysql')

    $db_vip = hiera('database_vip')
    $db_admin_user = 'root'
    $db_admin_pass = $mysql['root_password']
    $db_port = '3306'
    $db_options_file = '/root/.my.cnf'
    $db_file_content = inline_template('[client]
user=<%= @db_admin_user %>
password=<%= @db_admin_pass %>
host=<%= @db_vip %>
')

    file { $db_options_file:
      ensure  => file,
      content => $db_file_content,
    } ->
    mysql::db { $db_name:
      user     => $db_username,
      password => $db_password,
      host     => $db_vip,
    } ->
    class {'lma_monitoring_analytics::grafana':
      db_host        => "${db_vip}:${db_port}",
      db_name        => $db_name,
      db_username    => $db_username,
      db_password    => $db_password,
      admin_username => $admin_username,
      admin_password => $admin_password,
      domain         => $mgmt_vip,
    }
  }

  'remote': {
    # In this case we suppose that database has been created.
    class {'lma_monitoring_analytics::grafana':
      db_host        => $influxdb_grafana['mysql_host'],
      db_name        => $db_name,
      db_username    => $db_username,
      db_password    => $db_password,
      admin_username => $admin_username,
      admin_password => $admin_password,
      domain         => $mgmt_vip,
    }
  }

  default: {
    fail("'${db_mode}']}' database not supported for Grafana")
  }
}

