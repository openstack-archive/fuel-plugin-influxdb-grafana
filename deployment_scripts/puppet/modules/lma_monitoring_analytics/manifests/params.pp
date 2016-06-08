#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
# == Class lma_monitoring_analytics::params

class lma_monitoring_analytics::params {
  $influxdb_url                = 'http://localhost:8086'
  $influxdb_dir                = '/var/lib/influxdb'
  $influxdb_retention_period   = 'INF'
  $influxdb_replication_factor = 1
  $grafana_domain              = 'localhost'
  $grafana_address             = ''
  $grafana_port                = 8000
  $protocol                    = 'http'
}
