$influxdb_grafana = hiera('influxdb_grafana')

if $influxdb_grafana['node_name'] == hiera('user_node_name') {

  $directory = $influxdb_grafana['data_dir']
  $disks = split($::unallocated_pvs, ',')

  validate_array($disks)

  if empty($disks) {
    file { $directory:
      ensure => 'directory',
    }
  } else {
    disk_management::lvm_fs { $directory:
      disks   => $disks,
      lv_name => 'es',
      vg_name => 'data',
    }
  }
}
