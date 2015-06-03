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

$influxdb_grafana = hiera('influxdb_grafana')

if $influxdb_grafana['node_name'] == hiera('user_node_name') {
  $roles = hiera('roles')
  $blockdevices_array = split($::blockdevices, ',')

  # Check that we're not colocated with other roles
  if size($roles) > 1 {
    fail('The InfluxDB-Grafana plugin cannot be deployed with roles other than base-os.')
  }

  # Check that disk device(s) exist
  if ($influxdb_grafana['disk1']) and !($influxdb_grafana['disk1'] in $blockdevices_array) {
    fail("Disk device ${ influxdb_grafana['disk1'] } doesn't exist.")
  }

  if ($influxdb_grafana['disk2']) and !($influxdb_grafana['disk2'] in $blockdevices_array) {
    fail("Disk device ${ influxdb_grafana['disk2'] } doesn't exist.")
  }

  if ($influxdb_grafana['disk3']) and !($influxdb_grafana['disk3'] in $blockdevices_array) {
    fail("Disk device ${ influxdb_grafana['disk3'] } doesn't exist.")
  }
}

