$influxdb_grafana = hiera('influxdb_grafana')

if $influxdb_grafana['node_name'] == hiera('user_node_name') {

  # We want to be able to deploy this plugin with Elasticsearch-Kibana. So
  # we check if EK plugin is deployed and if it is the case we set the listen
  # port to 8000 instead of 80.
  $listen_port = inline_template("<% if File.directory?('/opt/kibana') -%> 8000 <% else -%> 80 <% end -%>")

  class {'lma_monitoring_analytics':
    listen_port       => $listen_port,
    influxdb_dbname   => $influxdb_grafana['influxdb_dbname'],
    influxdb_rootpass => $influxdb_grafana['influxdb_rootpass'],
    influxdb_username => $influxdb_grafana['influxdb_username'],
    influxdb_userpass => $influxdb_grafana['influxdb_userpass'],
  }
}
