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

Puppet::Type.type(:grafana_dashboard).provide(:grafana) do
    desc "Support for Grafana dashboards stored into Grafana"

    defaultfor :kernel => 'Linux'

    def backend_host
        unless @backend_host
            @backend_host = URI.parse(resource[:backend_url]).host
        end
        @backend_host
    end

    def backend_port
        unless @backend_port
            @backend_port = URI.parse(resource[:backend_url]).port
        end
        @backend_port
    end

    def backend_scheme
        unless @backend_scheme
            @backend_scheme = URI.parse(resource[:backend_url]).scheme
        end
        @backend_scheme
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
            self.backend_scheme, self.backend_host, self.backend_port,
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
        request.basic_auth resource[:backend_user], resource[:backend_password]

        return request
    end

    # Return the id of the dashboard which is the name's slug
    def dashboard_id
        unless @dashboard_id
            @dashboard_id = resource[:name].downcase
            @dashboard_id = @dashboard_id.gsub(/[^\w ]/, '').gsub(/ +/, '-')
        end
        @dashboard_id
    end

    def create
        data = {
            :dashboard => JSON.parse(resource[:content]),
            :overwrite => false
        }
        data[:dashboard]['id'] = nil
        data[:dashboard]['tags'] = resource[:tags].sort()
        data[:dashboard]['title'] = resource[:title]
        data[:dashboard]['version'] = 0

        req = self.build_request('POST', '/api/dashboards/db', data)
        response = Net::HTTP.start(self.backend_host, self.backend_port) do |http|
            http.request(req)
        end

        if response.code != '200'
            raise Puppet::Error, "Failed to create dashboard '%s' (HTTP "\
                "response: %s/'%s')" % [resource[:name], response.code,
                response.body]
        end
    end

    def destroy
        req = self.build_request('DELETE', '/api/dashboards/db/%s' % self.dashboard_id)
        response = Net::HTTP.start(self.backend_host, self.backend_port) do |http|
            http.request(req)
        end

        if response.code != '200'
            raise Puppet::Error, "Failed to delete dashboard '%s' (HTTP "\
                "response: %s/'%s')" % [resource[:name], response.code,
                response.body]
        end
    end

    def exists?
        req = self.build_request('GET', '/api/dashboards/db/%s' % self.dashboard_id)
        response = Net::HTTP.start(self.backend_host, self.backend_port) do |http|
            http.request(req)
        end

        if response.code == '200'
            return true
        elsif response.code == '404'
            return false
        else
            raise Puppet::Error , "Invalid response code %d from the backend"\
                " '%s'" % [response.code, response.body]
        end
    end
end
