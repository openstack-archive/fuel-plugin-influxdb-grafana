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

$influxdb_grafana = hiera('influxdb_grafana')

if $influxdb_grafana['tls_enabled'] {
  $certificate_content = $influxdb_grafana['grafana_ssl_cert']['content']
  $common_name = $influxdb_grafana['grafana_hostname']

  if ! validate_ssl_certificate($certificate_content, $common_name) {
    # Blocking errors like no private key, wrong CN or no date are exceptions
    # in valid_ssl_certificate(). If it is only the date that is incorrect
    # let's continue the deployment, log the error and the client will deal
    # with this error by accepting or denying the certificate.
    notice('Dates of the Grafana certificate are not valid')
  }
}
