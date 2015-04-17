# == Class: lma_monitoring_analytics::influxdb

class lma_monitoring_analytics::influxdb (
  $influxdb_dbname   = undef,
  $influxdb_username = undef,
  $influxdb_userpass = undef,
  $influxdb_rootpass = undef,
) inherits lma_monitoring_analytics::params {

  $configure_influxdb = $lma_monitoring_analytics::params::influxdb_script

  class { '::influxdb':
    install_from_repository => true,
  }

  file { $configure_influxdb:
    owner   => 'root',
    group   => 'root',
    mode    => '0740',
    content => template('lma_monitoring_analytics/configure_influxdb.sh.erb'),
    notify  => Exec['configure_influxdb_script']
  }

  exec { 'configure_influxdb_script':
    command => $configure_influxdb,
    require => Service['influxdb'],
  }
}
