# == Class lma_monitoring_analytics::params

class lma_monitoring_analytics::params {
  $influxdb_host      = undef
  $influxdb_script    = '/usr/local/bin/configure_influxdb.sh'
  $influxdb_grafanadb = 'grafana'
  $grafana_dir        = '/opt/grafana'
  $grafana_conf       = "${grafana_dir}/config.js"
  $grafana_dash       = "${grafana_dir}/app/dashboards/lma.json"
}
