LMA Monitoring Analytics module for Puppet
==========================================

Description
-----------

Puppet module for configuring the Grafana dashboard and InfluxDB.

Usage
-----

```puppet
class {'lma_monitoring_analytics':
  influxdb_dbname   => 'lma',
  influxdb_username => 'lma',
  influxdb_userpass => 'password',
  influxdb_rootpass => 'password',
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
