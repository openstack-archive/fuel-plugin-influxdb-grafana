$influxdb_grafana = hiera('influxdb_grafana')

if $influxdb_grafana['node_name'] == hiera('user_node_name') {

  class { 'disk_management': }

  if ($influxdb_grafana['disk1']) {
    disk_management::partition { "/dev/${influxdb_grafana['disk1']}":
      size    => $influxdb_grafana['disk1_size'],
      require => Class['disk_management'],
    }
  }

  if ($influxdb_grafana['disk2']) {
    disk_management::partition { "/dev/${influxdb_grafana['disk2']}":
      size    => $influxdb_grafana['disk2_size'],
      require => Class['disk_management'],
    }
  }

  if ($influxdb_grafana['disk3']) {
    disk_management::partition { "/dev/${influxdb_grafana['disk3']}":
      size    => $influxdb_grafana['disk3_size'],
      require => Class['disk_management'],
    }
  }
}
