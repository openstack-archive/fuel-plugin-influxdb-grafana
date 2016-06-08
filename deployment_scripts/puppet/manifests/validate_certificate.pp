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

notice('fuel-plugin-influxdb-grafana: validate_certificate.pp')

if hiera('lma::grafana::tls::enabled') {

  $certificate = hiera('lma::grafana::tls::cert_file_path')
  $common_name = hiera('lma::grafana::tls::hostname')

  # function validate_ssl_certificate() must be the value of a statement, so
  # we must use it in a statement.
  $not_used = validate_ssl_certificate($certificate, $common_name)
}
