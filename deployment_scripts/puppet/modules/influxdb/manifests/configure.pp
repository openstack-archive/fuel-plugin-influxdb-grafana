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
# == Class: influxdb::configure

class influxdb::configure {

  Ini_setting {
    ensure => present,
    path   => $influxdb::config_file,
  }

  # enable authentication in section [http]
  ini_setting { 'http_auth_enabled':
    section => 'http',
    setting => 'auth-enabled',
    value   => $influxdb::auth_enabled,
  }

  ini_setting { 'meta_dir':
    section => 'meta',
    setting => 'dir',
    value   => $influxdb::meta_dir,
  }

  ini_setting { 'data_dir':
    section => 'data',
    setting => 'dir',
    value   => $influxdb::data_dir,
  }

  ini_setting { 'hh_dir':
    section => 'hinted-handoff',
    setting => 'dir',
    value   => $influxdb::hh_dir,
  }
}
