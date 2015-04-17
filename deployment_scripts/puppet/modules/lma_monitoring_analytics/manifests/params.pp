# == Class lma_monitoring_analytics::params

class lma_monitoring_analytics::params {
  $listen_port            = 80
  $influxdb_host          = undef
  $influxdb_script        = '/usr/local/bin/configure_influxdb.sh'
  $grafana_dbname         = 'grafana'
  $grafana_dir            = '/opt/grafana'
  $grafana_conf           = "${grafana_dir}/config.js"
  $grafana_home_dashboard = '/dashboard/db/main'
}
