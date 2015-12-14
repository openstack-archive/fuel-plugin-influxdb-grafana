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
# == Class: influxdb::install

class influxdb::install (
  $hostname     = undef,
  $raft_cluster = undef,
) {

  package { 'influxdb':
    ensure => installed,
  }

  if ($hostname != undef) and ($raft_cluster != undef) {
    $content = inline_template('<% join_option = ""
@raft_cluster.sort.each do |n|
    join_option = join_option + n + ":8088,"
end -%>
INFLUXD_OPTS="-hostname <%= hostname %> -join <%= join_option[0...-1] %>"
')

    file { '/etc/default/influxdb':
        ensure  => present,
        content => $content,
    }
  }
}
