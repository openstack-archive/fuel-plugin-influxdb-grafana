$fuel_settings = parseyaml(file('/etc/astute.yaml'))

if $fuel_settings['influxdb_grafana']['node_name'] == $fuel_settings['user_node_name'] {

  class {'lma_monitoring_analytics':
    influxdb_dbname   => $fuel_settings['influxdb_grafana']['influxdb_dbname'],
    influxdb_rootpass => $fuel_settings['influxdb_grafana']['influxdb_rootpass'],
    influxdb_username => $fuel_settings['influxdb_grafana']['influxdb_username'],
    influxdb_userpass => $fuel_settings['influxdb_grafana']['influxdb_userpass'],
  }

}
