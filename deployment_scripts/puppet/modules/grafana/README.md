Grafana module for Puppet
=========================

Description
-----------

Puppet module for configuring the Grafana dashboard with InfluxDB.

Usage
-----

```puppet
class {'grafana':
  influxdb_host => 'influxdb-server',
  influxdb_user => 'user',
  influxdb_pass => 'password'
}
```

Limitations
-----------

None.

License
-------

Licensed under the terms of the Apache License, version 2.0.

Contact
-------

Guillaume Thouvenin, <gthouvenin@mirantis.com>

Support
-------

See the Contact section.
