# Copyright 2016 Mirantis, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
require 'spec_helper'

describe 'influxdb::install' do
    let(:facts) do
        {:kernel => 'Linux', :operatingsystem => 'Ubuntu',
         :osfamily => 'Debian'}
    end

    describe 'with defaults' do
        it { is_expected.to contain_package('influxdb').with_ensure('latest') }
        it { is_expected.to have_file_count(0) }
    end

    describe 'with version' do
        let (:params) do
            {:version => '0.1.2.3'}
        end
        it { is_expected.to contain_package('influxdb').with_ensure('0.1.2.3') }
        it { is_expected.to have_file_count(0) }
    end

    describe 'with raft nodes' do
        let(:params) do
            {:raft_nodes => ['node-1', 'node-2']}
        end
        it { is_expected.to contain_package('influxdb').with_ensure('latest') }
        it { is_expected.to contain_file('/etc/default/influxdb') }
    end
end
