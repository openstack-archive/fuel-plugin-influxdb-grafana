$influxdb_grafana = hiera('influxdb_grafana')
$elasticsearch_kibana = hiera('elasticsearch_kibana', undef)
$user_node_name = hiera('user_node_name')

if $influxdb_grafana['node_name'] == $user_node_name {

  # We want to be able to deploy this plugin with Elasticsearch-Kibana. So
  # we check if EK plugin is deployed and if it is the case we set the listen
  # port to 8000 instead of 80.
  if $elasticsearch_kibana {
    $listen_port = $elasticsearch_kibana['node_name'] ? {
      $user_node_name => 8000,
      default         => 80,
    }
  } else {
    $listen_port = 80
  }

  class {'lma_monitoring_analytics::grafana':
    listen_port       => $listen_port,
    influxdb_dbname   => $influxdb_grafana['influxdb_dbname'],
    influxdb_username => $influxdb_grafana['influxdb_username'],
    influxdb_userpass => $influxdb_grafana['influxdb_userpass'],
  }
}
