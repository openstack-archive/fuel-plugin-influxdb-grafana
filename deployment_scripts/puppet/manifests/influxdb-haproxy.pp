$influxdb_port = '8086'

openstack::ha::haproxy_service { 'influxdb':
  order                  => '800',
  listen_port            => $influxdb_port,
  balancermember_port    => $influxdb_port,
  haproxy_config_options => {
    'option'  => ['tcplog'],
    'balance' => 'roundrobin',
    'mode'    => 'tcp',
  },
  balancermember_options => "check port ${influxdb_port}",
  internal               => true,
  internal_virtual_ip    => hiera(influxdb_vip),
  public                 => false,
  public_virtual_ip      => undef,
  ipaddresses            => hiera(influxdb_raft_nodes_ip),
  server_names           => [ $::hostname ],
}
