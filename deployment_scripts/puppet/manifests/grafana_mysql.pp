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

$is_mysql_server = roles_include(['standalone-database',
                                  'primary-standalone-database'])

if hiera('lma::grafana::mysql::mode') == 'local' {
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
    $db_name = hiera('lma::grafana::mysql::dbname')
    $db_username = hiera('lma::grafana::mysql::username')
    $db_password = hiera('lma::grafana::mysql::password')

    file { $db_options_file:
      ensure  => file,
      content => $db_file_content,
      replace => false,
      notify  => Exec['remove_db_options_file'],
    }

    package { 'ubuntu-mysql-client':
      ensure => absent,
      name   => 'mysql-client',
    }

    # MOS uses its own mysql-client package
    class { '::mysql::client':
      package_name => 'mysql-client-5.6',
      require      => Package['ubuntu-mysql-client'],
    }

    mysql::db { $db_name:
      user     => $db_username,
      password => $db_password,
      # We use a wildcard because if several IPs are configured in the same
      # haproxy namespace we can't predict which one will be used as the
      # source IP address.
      host     => '%',
      require  => File[$db_options_file],
    }

    exec { 'remove_db_options_file':
      command     => "/bin/rm -f ${db_options_file}",
      refreshonly => true,
      require     => Mysql::Db[$db_name],
    }
}
