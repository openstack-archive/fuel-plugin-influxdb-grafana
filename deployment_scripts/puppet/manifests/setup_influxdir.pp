$influxdb_grafana = hiera('influxdb_grafana')

if $influxdb_grafana['node_name'] == hiera('user_node_name') {

  $directory = $influxdb_grafana['data_dir']
  $disks = split($::unallocated_pvs, ',')

  validate_array($disks)

  user { 'influxdb':
    ensure => present,
  }

  if empty($disks) {
    file { $directory:
      ensure => 'directory',
      owner  => 'influxdb',
      group  => 'influxdb',
    }
  } else {
    disk_management::lvm_fs { $directory:
      owner   => 'influxdb',
      group   => 'influxdb',
      disks   => $disks,
      lv_name => 'influxdb-data',
      vg_name => 'influxdb',
    }
  }
}
