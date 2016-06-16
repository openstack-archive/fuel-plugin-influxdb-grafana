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

describe 'lma_monitoring_analytics::grafana', :type => :class do
    let(:facts) do
        {:kernel => 'Linux', :operatingsystem => 'Ubuntu', :osfamily => 'Debian'}
    end

    describe 'with defaults' do
        let (:params) do
            {:db_host => 'localhost:3306',
             :db_name => 'grafana',
             :db_username => 'grafana',
             :db_password => 'grafana'}
        end
        it { is_expected.to contain_package('grafana').with(
            :ensure => 'latest'
        )}
        it { is_expected.to  contain_file('/etc/logrotate.d/grafana.conf') }
    end

    describe 'with ldap' do
        let (:params) do
            {:db_host => 'localhost:3306',
             :db_name => 'grafana',
             :db_username => 'grafana',
             :db_password => 'grafana',
             :ldap_enabled => true,
             :ldap_parameters => {
                 'servers' => 'localhost',
                 'protocol' => 'ldap',
                 'port' => 389,
                 'bind_dn' => 'cn=admin,dc=example,dc=com',
                 'bind_password' => 'pass',
                 'user_search_base_dns' => 'dc=example,dc=com',
                 'user_search_filter' => '(cn=%s)',
                 'authorization_enabled' => false,
                 'group_search_base_dns' => 'ou=groups,dc=example,dc=com',
                 'group_search_filter' => '(&(objectClass=posixGroup)(memberUid=%s))',
                 'admin_group_dn' => 'cn=admin_group,dc=example,dc=com',
                 'viewer_group_dn' => 'cn=viewer_group,dc=example,dc=com',
             }
            }
        end
        it do
            should contain_file('/etc/grafana/ldap.toml').with_content(/port\s*=\s*389/)
            should contain_file('/etc/grafana/ldap.toml').with_content(/use_ssl\s*=\s*false/)
        end
    end

    describe 'with ldaps' do
        let (:params) do
            {:db_host => 'localhost:3306',
             :db_name => 'grafana',
             :db_username => 'grafana',
             :db_password => 'grafana',
             :ldap_enabled => true,
             :ldap_parameters => {
                 'servers' => 'localhost',
                 'protocol' => 'ldaps',
                 'port' => '636',
                 'bind_dn' => 'cn=admin,dc=example,dc=com',
                 'bind_password' => 'pass',
                 'user_search_base_dns' => 'dc=example,dc=com',
                 'user_search_filter' => '(cn=%s)',
                 'authorization_enabled' => false,
                 'group_search_base_dns' => 'ou=groups,dc=example,dc=com',
                 'group_search_filter' => '(&(objectClass=posixGroup)(memberUid=%s))',
                 'admin_group_dn' => 'cn=admin_group,dc=example,dc=com',
                 'viewer_group_dn' => 'cn=viewer_group,dc=example,dc=com',
             }
            }
        end
        it do
            should contain_file('/etc/grafana/ldap.toml').with_content(/port\s*=\s*636/)
            should contain_file('/etc/grafana/ldap.toml').with_content(/use_ssl\s*=\s*true/)
        end
    end

    describe 'with ldap and groups' do
        let (:params) do
            {:db_host => 'localhost:3306',
             :db_name => 'grafana',
             :db_username => 'grafana',
             :db_password => 'grafana',
             :ldap_enabled => true,
             :ldap_parameters => {
                 'servers' => 'localhost',
                 'protocol' => 'ldap',
                 'port' => 389,
                 'bind_dn' => 'cn=admin,dc=example,dc=com',
                 'bind_password' => 'pass',
                 'user_search_base_dns' => 'dc=example,dc=com',
                 'user_search_filter' => '(cn=%s)',
                 'authorization_enabled' => true,
                 'group_search_base_dns' => 'ou=groups,dc=example,dc=com',
                 'group_search_filter' => '(&(objectClass=posixGroup)(memberUid=%s))',
                 'admin_group_dn' => 'cn=admin_group,dc=example,dc=com',
                 'viewer_group_dn' => 'cn=viewer_group,dc=example,dc=com',
             }
            }
        end
        it do
            should contain_file('/etc/grafana/ldap.toml').with_content(/group_dn = "cn=admin_group,dc=example,dc=com"/)
            should contain_file('/etc/grafana/ldap.toml').with_content(/group_dn = "cn=viewer_group,dc=example,dc=com"/)
        end
    end

    describe 'db_host without port number' do
        let (:params) do
            {:db_host => 'www.example.com',
             :db_name => 'grafana',
             :db_username => 'grafana',
             :db_password => 'grafana'}
        end
        it { is_expected.to contain_package('grafana').with(
            :ensure => 'latest'
        )}
    end
end
