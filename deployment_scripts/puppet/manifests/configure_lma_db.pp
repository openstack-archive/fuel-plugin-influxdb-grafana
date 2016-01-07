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
$influxdb_grafana = hiera('influxdb_grafana')

lma_monitoring_analytics::influxdb_create_db { 'lma':
  rootuser         => 'root',
  rootpass         => $influxdb_grafana['influxdb_rootpass'],
  username         => $influxdb_grafana['influxdb_username'],
  userpass         => $influxdb_grafana['influxdb_userpass'],
  retention_period => $influxdb_grafana['retention_period'],
}
