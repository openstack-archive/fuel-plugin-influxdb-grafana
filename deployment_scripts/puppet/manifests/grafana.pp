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
$influxdb_grafana = hiera('influxdb_grafana')
$elasticsearch_kibana = hiera('elasticsearch_kibana', undef)
$user_node_name = hiera('user_node_name')

if $influxdb_grafana['node_name'] == $user_node_name {

  # We want to be able to deploy this plugin with Elasticsearch-Kibana. So
  # we check if EK plugin is deployed and if it is the case we set the listen
  # port to 8000 instead of 80.
  if $elasticsearch_kibana {
    $listen_port = $elasticsearch_kibana['node_name'] ? {
      $user_node_name => 8000,
      default         => 80,
    }
  } else {
    $listen_port = 80
  }

  class {'lma_monitoring_analytics::grafana':
    listen_port       => $listen_port,
    influxdb_dbname   => $influxdb_grafana['influxdb_dbname'],
    influxdb_username => $influxdb_grafana['influxdb_username'],
    influxdb_userpass => $influxdb_grafana['influxdb_userpass'],
  }
}
