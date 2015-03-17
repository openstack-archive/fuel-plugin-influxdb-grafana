$fuel_settings = parseyaml(file('/etc/astute.yaml'))

if $fuel_settings['influxdb_grafana']['node_name'] == $fuel_settings['user_node_name'] {

  class { 'influxdb':
    install_from_repository => true,
  }

}
