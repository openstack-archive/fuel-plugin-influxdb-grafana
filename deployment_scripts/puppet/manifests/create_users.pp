#    Copyright 2016 Mirantis, Inc.
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
$influxdb_grafana = hiera('influxdb_grafana')

$admin_user = 'root'
$admin_password = $influxdb_grafana['influxdb_rootpass']

lma_monitoring_analytics::influxdb_user { $admin_user:
  password     => $admin_password,
  admin_role   => true,
  influxdb_url => 'http://127.0.0.1:8086',
}

$username = $influxdb_grafana['influxdb_username']

lma_monitoring_analytics::influxdb_user { $username:
  admin_user     => $admin_user,
  admin_password => $admin_password,
  password       => $influxdb_grafana['influxdb_userpass'],
  influxdb_url   => 'http://127.0.0.1:8086',
  require        => Lma_monitoring_analytics::Influxdb_user[$admin_user],
}
