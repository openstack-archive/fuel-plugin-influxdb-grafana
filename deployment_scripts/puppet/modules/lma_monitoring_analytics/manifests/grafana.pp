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
# == Class: lma_monitoring_analytics::grafana

class lma_monitoring_analytics::grafana (
    $db_username = undef,
    $db_password = undef,
    $http_port   = $lma_monitoring_analytics::params::listen_port,
) inherits lma_monitoring_analytics::params {
  class { '::grafana':
    install_method      => 'repo',
    manage_package_repo => false,
    cfg                 => {
      server   => {
        http_port => $http_port,
      },
      database => {
        name     => $db_username,
        password => $db_password,
      },
    },
  }
}
