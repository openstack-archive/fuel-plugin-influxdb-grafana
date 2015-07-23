InfluxDB module for Puppet
==========================

Description
-----------

Puppet module for installing and configuring InfluxDB 0.9.x.

Usage
-----

```puppet
class {'influxdb':
  meta_dir => '/opt/influxdb/meta'
  data_dir => '/opt/influxdb/data'
  hh_dir   => '/opt/influxdb/hh'
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
