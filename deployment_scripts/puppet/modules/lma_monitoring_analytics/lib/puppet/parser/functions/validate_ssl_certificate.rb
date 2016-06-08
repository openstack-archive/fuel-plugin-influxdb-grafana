# Copied from https://github.com/camptocamp/puppet-openssl
# Original name: cert_date_valid.rb
#
# Function: validate_ssl_certificate()
#
# Checks SSL certificate date and CN validity. It also checks that the private
# key is embedded into the certificate.
#
# It raises an exception if:
#   - the certificate has no private key
#   - the CN of the certificate and the CN provided as argument don't match
#   - the date is not found in the certificate
#
# It returns false if the certificate is expired or not yet valid
# Otherwise it returns the number of seconds before the certificate expires
#
# Parameter:
#   - the content of the SSL certificate
#   - the expected CN

module Puppet::Parser::Functions
    newfunction(:validate_ssl_certificate, :type => :rvalue) do |args|

        require 'tempfile'
        require 'time'

        file = Tempfile.new('certificate')
        begin
          cert_content = args[0]
          file.write(cert_content)
          file.close
          dates   = `openssl x509 -dates -noout -in #{file.path}`.gsub("\n", '')
          subject = `openssl x509 -subject -noout -in #{file.path}`.gsub("\n", '')
          pk      = `openssl rsa -check -noout -in #{file.path}`.gsub("\n",'')

          cn        = subject.match(/CN=(.*)$/)[1]
          certbegin = Time.parse(dates.gsub(/.*notBefore=(.+? GMT).*/, '\1'))
          certend   = Time.parse(dates.gsub(/.*notAfter=(.+? GMT).*/, '\1'))
          now       = Time.now
        ensure
          file.unlink
        end

        raise "Private key not found" unless pk == 'RSA key ok'
        raise "Found #{cn} as CN where #{args[1]} was expected" unless cn == args[1]
        raise "Dates not found in the certificate" unless dates.match(/not(Before|After)=/)

        if (now > certend)
            Puppet.warning('certificate is expired')
            false
        elsif (now < certbegin)
            Puppet.warning('certificate is not yet valid')
            false
        elsif (certend <= certbegin)
            Puppet.warning('certificate will never be valid')
            false
        else
            # return number of seconds certificate is still valid for
            (certend - now).to_i
        end

    end
end
