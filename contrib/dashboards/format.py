#!/usr/bin/python3
#    Copyright 2016 Mirantis, Inc.
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

import sys
import glob
import os
import json


def usage():
    h = """
    Format JSON file with ordered keys.
    Remove sections:
        templating.list[].current
        templating.list[].options
    Override time entry to {{"from": "now-1h","to": "now"}}
    Enable sharedCrosshair
    Increment the version

    WARNING: this script modifies all manipulated files.

    Usage: {} <DIRECTORY|FILE>

    if a DIRECTORY is provided, all files with suffix '.json' will be modified.
    """
    print(h.format(sys.argv[0]))

if len(sys.argv) != 2:
    usage()
    sys.exit(1)

arg = sys.argv[1]

if os.path.isdir(arg):
    path = "{}/*.json".format(arg)
elif os.path.isfile(arg):
    path = arg
else:
    print("'{}' no such file or directory".format(arg))
    usage()
    sys.exit(1)

for f in glob.glob(path):
    data = None
    absf = os.path.abspath(f)
    with open(absf) as out:
        data = json.load(out)
    for k, v in data.items():
        if k == 'annotations':
            for anno in v.get('list', []):
                anno['datasource'] = 'lma'

        if k == 'templating':
            variables = v.get('list', [])
            for o in variables:
                if o['type'] == 'query':
                    o['options'] = []
                    o['current'] = {}
                    o['refresh_on_load'] = True

    data['time'] = {'from': 'now-1h', 'to': 'now'}
    data['sharedCrosshair'] = True
    data['refresh'] = '1m'
    data['id'] = None

    if data.get('version', None):
        data['version'] = data['version'] + 1
    else:
        data['version'] = 1

    with open(absf, 'w') as out:
        out.write(json.dumps(data, indent=2, sort_keys=True))
