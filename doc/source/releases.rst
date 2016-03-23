.. _releases:

Release Notes
=============

Version 0.8.1
-------------

* Bug fixes

  * Fix the nologin path (`#1523579
    <https://bugs.launchpad.net/lma-toolchain/+bug/1523579>`_).
  * Remove duplicate crontab for log rotation (`#1535440
    <https://bugs.launchpad.net/lma-toolchain/+bug/1535440>`_).
  * Fix the number of keystone-admin-api down (`#1533653
    <https://bugs.launchpad.net/lma-toolchain/+bug/1533653>`_).

Version 0.8.0
-------------

- Add support for the "influxdb_grafana" Fuel Plugin role instead of
  the "base-os" role which had several limitations.
- Add support for retention policy configuration.
- Upgrade to InfluxDB 0.9.4 which brings metrics time-series with tagging.
- Upgrade to Grafana 2.5.0.
- Several dashboard visualisation improvements.
- A new self-monitoring dashboard.

Version 0.7.0
-------------

- Initial release of the plugin. This is a beta version.
