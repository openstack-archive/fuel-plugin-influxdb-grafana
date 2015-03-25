$influxdb_grafana = hiera('influxdb_grafana')

if $influxdb_grafana['node_name'] == hiera('user_node_name') {

  class { 'influxdb':
    install_from_repository => true,
  }
}
