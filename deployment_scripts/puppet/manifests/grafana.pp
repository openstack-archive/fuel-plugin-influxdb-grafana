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
$mgmt_address = get_network_role_property('management', 'ipaddr')
$influxdb_grafana = hiera('influxdb_grafana')
$db_mode = $influxdb_grafana['grafana_db']

case $db_mode {

  'local': {
    $mysql  = hiera('mysql')

    $db_vip = hiera(database_vip)
    $db_name = 'grafana'
    $db_user = 'grafana'
    $db_pass = 'grafana'
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
      user     => $db_user,
      password => $db_pass,
      host     => $db_vip,
    } ->
    class {'lma_monitoring_analytics::grafana':
      db_host           => "${db_vip}:${db_port}",
      db_user           => $db_user,
      db_password       => $db_pass,
      admin_username    => $influxdb_grafana['grafana_username'],
      admin_password    => $influxdb_grafana['grafana_userpass'],
      influxdb_username => $influxdb_grafana['influxdb_username'],
      influxdb_password => $influxdb_grafana['influxdb_userpass'],
      influxdb_database => $influxdb_grafana['influxdb_dbname'],
      domain            => $mgmt_address,
      datasource        => hiera('lma::influxdb::vip'),
    }
  }

  'remote': {
    # In this case we suppose that a DB named 'grafana' has been created.
    class {'lma_monitoring_analytics::grafana':
      db_host           => $influxdb_grafana['grafana_dbhost'],
      db_user           => $influxdb_grafana['grafana_dbuser'],
      db_password       => $influxdb_grafana['grafana_dbpassword'],
      admin_username    => $influxdb_grafana['grafana_username'],
      admin_password    => $influxdb_grafana['grafana_userpass'],
      influxdb_username => $influxdb_grafana['influxdb_username'],
      influxdb_password => $influxdb_grafana['influxdb_userpass'],
      influxdb_database => $influxdb_grafana['influxdb_dbname'],
      domain            => $mgmt_address,
    }
  }

  default: {
    fail("'${db_mode}']}' database not supported for Grafana")
  }
}

