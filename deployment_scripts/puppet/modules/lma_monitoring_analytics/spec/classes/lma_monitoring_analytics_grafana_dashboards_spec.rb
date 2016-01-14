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
require 'spec_helper'

describe 'lma_monitoring_analytics::grafana_dashboards', :type => :class do
    let(:facts) do
        {:kernel => 'Linux', :operatingsystem => 'Ubuntu', :osfamily => 'Debian'}
    end

    describe 'with defaults' do
        let (:params) do {:admin_username => 'admin', :admin_password => 'pass'} end
        it { is_expected.to contain_grafana_dashboard('Main') }
    end
end
