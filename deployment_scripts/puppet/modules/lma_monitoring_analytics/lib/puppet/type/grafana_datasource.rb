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
require 'json'

Puppet::Type.newtype(:grafana_datasource) do
    @doc = "Manage datasources in Grafana"

    ensurable

    newparam(:name) do
        desc "The name of the datasource."

        isnamevar
    end

    newparam(:grafana_url) do
        desc "The URL of the Grafana server."
        defaultto ""

        validate do |value|
            unless value =~ /^https?:\/\//
                raise ArgumentError , "'%s' is not a valid URL" % value
            end
        end
    end

    newparam(:grafana_user) do
        desc "The username for the Grafana server."
    end

    newparam(:grafana_password) do
        desc "The password for the Grafana server."
    end

    newparam(:url) do
        desc "The URL of the backend."
        defaultto ""

        validate do |value|
            unless value =~ /^https?:\/\//
                raise ArgumentError , "'%s' is not a valid URL" % value
            end
        end
    end

    newparam(:type) do
        # We support only InfluxDB 0.9 for now
        desc "The datasource type."
        newvalues(:influxdb)
        defaultto :influxdb
    end

    newparam(:user) do
        desc "The username for the backend (optional)."
    end

    newparam(:password) do
        desc "The password for the backend (optional)."
    end

    newparam(:database) do
        desc "The name of the database (optional)."
    end

    newparam(:access_mode) do
        desc "Whether the datasource is accessed directly or not by the clients."
        newvalues(:direct, :proxy)
        defaultto :direct
    end

    newparam(:is_default) do
        desc "Whether the datasource is the default."
        newvalues(:true, :false)
        defaultto :false
    end

    newparam(:json_data) do
        desc "Additional JSON data to configure the datasource (optional)."

        validate do |value|
            begin
                JSON.parse(value)
            rescue JSON::ParserError
                raise ArgumentError , "Invalid JSON data"
            end
        end
    end
end
