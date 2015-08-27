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

  $directory = $influxdb_grafana['data_dir']
  $disks = split($::unallocated_pvs, ',')

  validate_array($disks)

  user { 'influxdb':
    ensure => present,
    system => true,
  }

  if empty($disks) {
    file { $directory:
      ensure  => 'directory',
      owner   => 'influxdb',
      group   => 'influxdb',
      require => User['influxdb'],
    }
  } else {
    disk_management::lvm_fs { $directory:
      owner   => 'influxdb',
      group   => 'influxdb',
      disks   => $disks,
      lv_name => 'influxdb-data',
      vg_name => 'influxdb',
      require => User['influxdb'],
    }
  }
}
