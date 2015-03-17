# == Class: grafana

class grafana (
  $influxdb_host = $grafana::params::influxdb_host,
  $influxdb_user = undef,
  $influxdb_pass = undef,
) inherits grafana::params {

  $grafana_dir  = $grafana::params::grafana_dir
  $grafana_conf = $grafana::params::grafana_conf
  $grafana_dash = $grafana::params::grafana_dash

  # Deploy sources.
  file { $grafana_dir:
    source  => "puppet::///modules/grafana/sources",
    recurse => true,
  }

  # Replace config.js
  file { $grafana_conf:
    ensure  => file,
    content => template('grafana/config.js.erb'),
    require => File[${grafana_dir}],
  }

  # Install the dashboard
  file { $grafana_dash:
    source  => "puppet:///modules/grafana/dashboards/lma.json",
    require => File[${grafana_dir}],
  }

  # And now install nginx
  class { 'nginx':
    manage_repo           => false,
    nginx_vhosts          => {'grafana.local' => { 'www.root' => $grafana_dir }},
    nginx_vhosts_defaults => {'listen_options' => 'default_server'},
    require               => File[${grafana_conf}],
  }

}
