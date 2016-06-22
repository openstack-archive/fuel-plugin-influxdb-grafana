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

notice('fuel-plugin-influxdb-grafana: influxdb_configuration.pp')

# We are using the local IP address instead of the VIP to avoid race condition
# between the creation of the admin user and the normal user.
$local_address = hiera('lma::influxdb::listen_address')
$local_port = hiera('lma::influxdb::influxdb_port')
$influxdb_url = "http://${local_address}:${local_port}"

$admin_user = hiera('lma::influxdb::admin_username')
$admin_password = hiera('lma::influxdb::admin_password')
$username = hiera('lma::influxdb::username')
$password = hiera('lma::influxdb::password')
$retention_period = hiera('lma::influxdb::retention_period')
$replication_factor = hiera('lma::influxdb::replication_factor')

lma_monitoring_analytics::influxdb_user { $admin_user:
  password     => $admin_password,
  admin_role   => true,
  influxdb_url => $influxdb_url,
}

lma_monitoring_analytics::influxdb_user { $username:
  admin_user     => $admin_user,
  admin_password => $admin_password,
  password       => $password,
  influxdb_url   => $influxdb_url,
  require        => Lma_monitoring_analytics::Influxdb_user[$admin_user],
}

lma_monitoring_analytics::influxdb_database { 'lma':
  admin_user         => $admin_user,
  admin_password     => $admin_password,
  influxdb_url       => $influxdb_url,
  db_user            => $username,
  db_password        => $password,
  retention_period   => $retention_period,
  replication_factor => $replication_factor,
  require            => Lma_monitoring_analytics::Influxdb_user[$username],
}
