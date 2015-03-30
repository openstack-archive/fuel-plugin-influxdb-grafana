require 'base64'
require 'json'
require 'net/http'

Puppet::Type.type(:grafana_dashboard).provide(:influxdb) do
    desc "Support for Grafana dashboards stored into InfluxDB"

    defaultfor :kernel => 'Linux'

    def build_uri(q="")
        params = {
            :u => resource[:storage_user],
            :p => resource[:storage_password],
        }
        if q
            params[:q] = q
        end
        URI("%s/series?%s" % [resource[:storage_url],
                              URI.encode_www_form(params)])
    end

    def dashboard_id
        unless @dashboard_id
            @dashboard_id = resource[:name].downcase
            @dashboard_id = @dashboard_id.gsub(/[^\w ]/, '').gsub(/ +/, '-')
        end
        @dashboard_id
    end

    def self.serie_prefix
        "grafana.dashboard_"
    end

    def serie_name
        @serie_name ||= self.class.serie_prefix +
            Base64.encode64(self.dashboard_id).chomp()
        @serie_name
    end

    def create
        data = [{
            :name => self.serie_name,
            :columns => [
                "time", "sequence_number", "title", "tags", "dashboard", "id"
            ],
            :points => [[
                1000000000000,
                1,
                resource[:name],
                resource[:tags].sort().join(','),
                resource[:content],
                self.dashboard_id
            ]]
        }].to_json
        uri = self.build_uri
        response = Net::HTTP::start(uri.host, uri.port) do |http|
            req = Net::HTTP::Post.new(uri.request_uri)
            req.body = data
            req.content_type = 'application/json'

            http.request(req)
        end
        if response.code != '200'
            raise Puppet::Error, "Failed to create dashboard '%s' (HTTP "\
                "response: %s/'%s')" % [resource[:name], response.code,
                response.body]
        end
    end

    def destroy
        uri = self.build_uri('drop series "%s"' % self.serie_name)
        response = Net::HTTP.start(uri.host, uri.port) do |http|
            req = Net::HTTP::Get.new(uri.request_uri)

            http.request(req)
        end

        if response.code != '200'
            raise Puppet::Error, "Failed to delete dashboard '%s' (HTTP "\
                "response: %s/'%s')" % [resource[:name], response.code,
                response.body]
        end
    end

    def exists?
        uri = self.build_uri('list series /^%s$/' % self.serie_name)
        response = Net::HTTP.start(uri.host, uri.port) do |http|
            req = Net::HTTP::Get.new(uri.request_uri)

            http.request(req)
        end

        if response.code == '200'
            begin
                res = JSON.parse(response.body)
                res.first["points"].size() > 0
            rescue JSON::ParserError
                raise Puppet::Error , "Invalid JSON response from the backend"\
                    " '%s'" % response.body
            end
        else
            raise Puppet::Error , "Invalid response from the backend"\
                " '%s'" % response.body
        end
    end
end
