$influxdb_port = '8086'
$influxdb_nodes = hiera(lma::influxdb::raft_nodes)

openstack::ha::haproxy_service { 'influxdb':
  order                  => '800',
  listen_port            => $influxdb_port,
  balancermember_port    => $influxdb_port,
  haproxy_config_options => {
    'option'  => ['httplog'],
    'balance' => 'roundrobin',
    'mode'    => 'http',
  },
  balancermember_options => "check port ${influxdb_port}",
  internal               => true,
  internal_virtual_ip    => hiera(lma::influxdb::vip),
  public                 => false,
  public_virtual_ip      => undef,
  ipaddresses            => values($influxdb_nodes),
  server_names           => keys($influxdb_nodes),
}
