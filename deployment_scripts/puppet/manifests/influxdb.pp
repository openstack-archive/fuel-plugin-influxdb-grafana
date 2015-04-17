$influxdb_grafana = hiera('influxdb_grafana')

if $influxdb_grafana['node_name'] == hiera('user_node_name') {

  class { 'lma_monitoring_analytics::influxdb':
    influxdb_rootpass => $influxdb_grafana['influxdb_rootpass'],
    influxdb_dbname   => $influxdb_grafana['influxdb_dbname'],
    influxdb_username => $influxdb_grafana['influxdb_username'],
    influxdb_userpass => $influxdb_grafana['influxdb_userpass'],
  }
}
