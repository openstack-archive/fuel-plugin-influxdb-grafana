$influxdb_grafana = hiera('influxdb_grafana')

if $influxdb_grafana['node_name'] == hiera('user_node_name') {

  class { 'influxdb':
    install_from_repository => true,
    # Currently the usage of storage_dir prevent the installation of influxdb.
    # We need to figure out why.
    #storage_dir             => $influxdb_grafana['data_dir'],
  }
}
