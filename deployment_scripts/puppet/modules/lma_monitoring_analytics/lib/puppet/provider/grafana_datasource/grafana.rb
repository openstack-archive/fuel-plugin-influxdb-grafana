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
require 'cgi'
require 'json'
require 'net/http'

Puppet::Type.type(:grafana_datasource).provide(:grafana) do
    desc "Support for Grafana datasources"

    defaultfor :kernel => 'Linux'

    def host
        unless @host
            @host = URI.parse(resource[:grafana_url]).host
        end
        @host
    end

    def port
        unless @port
            @port = URI.parse(resource[:grafana_url]).port
        end
        @port
    end

    def scheme
        unless @scheme
            @scheme = URI.parse(resource[:grafana_url]).scheme
        end
        @scheme
    end

    def resource_id
        @resource_id
    end

    # Return a Net::HTTP::Request object
    def build_request(operation="GET", path="", data=nil, search_path={})
        request = nil
        encoded_search = ""

        if URI.respond_to?(:encode_www_form)
            encoded_search = URI.encode_www_form(search_path)
        else
            # Ideally we would have use URI.encode_www_form but it isn't
            # available with Ruby 1.8.x that ships with CentOS 6.5.
            encoded_search = search_path.to_a.map do |x|
                x.map{|y| CGI.escape(y.to_s)}.join('=')
            end
            encoded_search = encoded_search.join('&')
        end
        uri = URI.parse("%s://%s:%d%s?%s" % [
            self.scheme, self.host, self.port,
            path, encoded_search])

        case operation.upcase
        when 'POST'
            request = Net::HTTP::Post.new(uri.request_uri)
            request.body = data.to_json()
        when 'GET'
            request = Net::HTTP::Get.new(uri.request_uri)
        when 'DELETE'
            request = Net::HTTP::Delete.new(uri.request_uri)
        else
            raise Puppet::Error, "Unsupported HTTP operation '%s'" % operation
        end

        request.content_type = 'application/json'
        request.basic_auth resource[:grafana_user], resource[:grafana_password]

        return request
    end

    def create
        data = {
            :name => resource[:name],
            :type => resource[:type],
            :url => resource[:url],
            :access => resource[:access_mode],
            :database => resource[:database],
            :user => resource[:user],
            :password => resource[:password],
            :isDefault => (resource[:is_default] == :true),
            :jsonData => resource[:json_data],
        }

        req = self.build_request('POST', '/api/datasources', data)
        response = Net::HTTP.start(self.host, self.port) do |http|
            http.request(req)
        end

        if response.code != '200'
            raise Puppet::Error, "Failed to create datasource '%s' (HTTP "\
                "response: %s/'%s')" % [resource[:name], response.code,
                response.body]
        end
    end

    def destroy
        req = self.build_request('DELETE', '/api/datasources/%s' % self.resource_id)
        response = Net::HTTP.start(self.host, self.port) do |http|
            http.request(req)
        end

        if response.code != '200'
            raise Puppet::Error, "Failed to delete datasource '%s' (HTTP "\
                "response: %s/'%s')" % [resource[:name], response.code,
                response.body]
        end
    end

    def exists?
        @resource_id = nil

        req = self.build_request('GET', '/api/datasources')
        response = Net::HTTP.start(self.host, self.port) do |http|
            http.request(req)
        end

        if response.code == '200'
            sources = JSON.parse(response.body)
            sources.each do |x|
                if x["name"] == resource[:name]
                    @resource_id = x["id"]
                    break
                end
            end
            return @resource_id
        else
            raise Puppet::Error , "Invalid response code %d from Grafana"\
                " '%s'" % [response.code, response.body]
        end
    end
end
