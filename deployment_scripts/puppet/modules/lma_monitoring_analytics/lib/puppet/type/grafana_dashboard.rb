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

    newparam(:storage_url) do
        desc "The URL of the storage backend"
        defaultto ""

        validate do |value|
            unless value =~ /^https?:\/\//
                raise ArgumentError , "'%s' is not a valid storage URL" % value
            end
        end
    end

    newparam(:storage_user) do
        desc "The username for the storage backend (optional)"
    end

    newparam(:storage_password) do
        desc "The password for the storage backend (optional)"
    end
end
