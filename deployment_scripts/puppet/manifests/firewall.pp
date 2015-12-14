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

class {'::firewall':}

firewall { '113 corosync-input':
  port   => 5404,
  proto  => 'udp',
  action => 'accept',
}

firewall { '114 corosync-output':
  port   => 5405,
  proto  => 'udp',
  action => 'accept',
}

firewall { '200 influxdb':
  port   => [8083, 8086, 8088],
  proto  => 'tcp',
  action => 'accept',
}

firewall { '201 grafana':
  port   => 8000,
  proto  => 'tcp',
  action => 'accept',
}

firewall { '999 drop all other requests':
  proto  => 'all',
  chain  => 'INPUT',
  action => 'drop',
}
