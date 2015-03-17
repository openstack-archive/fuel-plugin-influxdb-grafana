# == Class grafana::params

class grafana::params {
  $influxdb_host = "window.location.hostname"
  $grafana_dir   = "/opt/grafana"
  $grafana_conf  = "${grafana_dir}/config.js"
  $grafana_dash  = "${grafana_dir}/app/dashboards/lma.json"
}
