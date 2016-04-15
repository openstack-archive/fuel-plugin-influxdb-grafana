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

notice('StackLight: influxdb-grafana/influxdb_configuration.pp')

prepare_network_config(hiera('network_scheme', {}))
$mgmt_address = get_network_role_property('management', 'ipaddr')

$influxdb_grafana = hiera('influxdb_grafana')

$admin_user = 'root'
$admin_password = $influxdb_grafana['influxdb_rootpass']
$username = $influxdb_grafana['influxdb_username']
$password = $influxdb_grafana['influxdb_userpass']
$retention_period = $influxdb_grafana['retention_period']
$replication_factor = $influxdb_grafana['replication_factor']

lma_monitoring_analytics::influxdb_user { $admin_user:
  password     => $admin_password,
  admin_role   => true,
  # We are using the management IP instead of the VIP to avoid race condition
  # between the creation of the admin user and the normal user.
  influxdb_url => "http://${mgmt_address}:8086",
}

lma_monitoring_analytics::influxdb_user { $username:
  admin_user     => $admin_user,
  admin_password => $admin_password,
  password       => $password,
  influxdb_url   => "http://${mgmt_address}:8086",
  require        => Lma_monitoring_analytics::Influxdb_user[$admin_user],
}

lma_monitoring_analytics::influxdb_database { 'lma':
  admin_user         => $admin_user,
  admin_password     => $admin_password,
  influxdb_url       => "http://${mgmt_address}:8086",
  db_user            => $username,
  db_password        => $password,
  retention_period   => $retention_period,
  replication_factor => $replication_factor,
  require            => Lma_monitoring_analytics::Influxdb_user[$username],
}
