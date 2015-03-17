$fuel_settings = parseyaml(file('/etc/astute.yaml'))

if $fuel_settings['influxdb_grafana']['node_name'] == $fuel_settings['user_node_name'] {

  class {'grafana':
    influxdb_user => $fuel_settings['influxdb_grafana']['influxdb_user'],
    influxdb_pass => $fuel_settings['influxdb_grafana']['influxdb_pass'],
  }

}
