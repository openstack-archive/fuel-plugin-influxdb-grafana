# Copied from https://github.com/camptocamp/puppet-openssl
# Original: cert_date_valid.rb

module Puppet::Parser::Functions
    newfunction(:cert_date_valid, :type => :rvalue) do |args|

        require 'time'

        file = Tempfile.new('certif')
        begin
          cert_content = args[0]
          file.write(cert_content)
          file.rewind
          dates = `openssl x509 -dates -noout < #{file.path}`.gsub("\n", '')
        ensure
          file.close
          file.unlink
        end

        raise "No date found in certificate" unless dates.match(/not(Before|After)=/)

        certbegin = Time.parse(dates.gsub(/.*notBefore=(.+? GMT).*/, '\1'))
        certend   = Time.parse(dates.gsub(/.*notAfter=(.+? GMT).*/, '\1'))
        now       = Time.now

        if (now > certend)
            # certificate is expired
            false
        elsif (now < certbegin)
            # certificate is not yet valid
            false
        elsif (certend <= certbegin)
            # certificate will never be valid
            false
        else
            # return number of seconds certificate is still valid for
            (certend - now).to_i
        end

    end
end
