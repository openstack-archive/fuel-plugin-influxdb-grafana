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

notice('fuel-plugin-influxdb-grafana: grafana_mysql.pp')

$influxdb_grafana = hiera('influxdb_grafana')
$is_mysql_server = roles_include(['standalone-database',
                                  'primary-standalone-database'])

if $influxdb_grafana['mysql_mode'] == 'local' {
    $mysql  = hiera_hash('mysql')
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
    $db_name = $influxdb_grafana['mysql_dbname']
    $db_username = $influxdb_grafana['mysql_username']
    $db_password = $influxdb_grafana['mysql_password']

    exec { 'test_and_backup_db_options_file':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "mv ${db_options_file} ${db_options_file}.fp-bak",
      onlyif  => "test -e ${db_options_file}",
    }

    file { $db_options_file:
      ensure  => file,
      content => $db_file_content,
      require => Exec['test_and_backup_db_options_file'],
    }

    if $is_mysql_server {
      # The plugin detach database installs a mysql-client-X.Y that may not be
      # compatible with the mysql-client metadata that is installed by mysql
      # module. So in this case we just use the client that is installed by
      # the detach database plugin.
      class { '::mysql::client':
        package_manage => false,
      }
    }

    mysql::db { $db_name:
      user     => $db_username,
      password => $db_password,
      host     => $db_vip,
      require  => File[$db_options_file],
    }

    exec { 'remove_db_options_file':
      command => "/bin/rm -f ${db_options_file}",
      require => Mysql::Db[$db_name],
    }

    exec { 'test_and_restore_backup_db_options_file':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "mv ${db_options_file}.fp-bak ${db_options_file}",
      onlyif  => "test -e ${db_options_file}.fp-bak",
      require => Exec['remove_db_options_file'],
    }
}
