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

Puppet::Type.newtype(:grafana_dashboard) do
    @doc = "Manage dashboards in Grafana"

    ensurable

    newparam(:title) do
        desc "The title of the dashboard."

        isnamevar
    end

    newparam(:content) do
        desc "The JSON representation of the dashboard."

        validate do |value|
            begin
                JSON.parse(value)
            rescue JSON::ParserError
                raise ArgumentError , "Invalid JSON string for Grafana dashboard"
            end
        end
    end

    newparam(:tags) do
        desc "Tags associated to the dashboard"
        defaultto []

        validate do |value|
            unless value.is_a?(Array)
                raise ArgumentError , "Grafana tags must be an array"
            end
        end
    end

    newparam(:backend_url) do
        desc "The URL of the storage backend"
        defaultto ""

        validate do |value|
            unless value =~ /^https?:\/\//
                raise ArgumentError , "'%s' is not a valid backenb URL" % value
            end
        end
    end

    newparam(:backend_user) do
        desc "The username for the storage backend (optional)"
    end

    newparam(:backend_password) do
        desc "The password for the storage backend (optional)"
    end
end
