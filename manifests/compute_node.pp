#
# == Class one::compute_node
#
# Installs OpenNebula required packages and configuration files for OpenNebula
# virtualization hosts
#
# === Author
# ePost Development GmbH
# (c) 2013
#
# Contributors:
# - Martin Alfke
# - Achim Ledermueller (Netways)
# - Sebastian Saemann (Netways)
#
# === Parameters
# none
#
# === Usage
#
# do not use this class directly. Use class one instead.
# See documentation in one/manifests/init.pp
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::compute_node {
  include one::prerequisites
  include one::params
  include one::install
  include one::config
  include one::service
  include one::compute_node::config
  include one::compute_node::service
  include one::compute_node::install

  Class['one::prerequisites'] ->
  Class['one::params'] ->
  Class['one::install'] ->
  Class['one::config'] ->
  Class['one::compute_node::install'] ->
  Class['one::compute_node::config'] ->
  Class['one::compute_node::service'] ->
  Class['one::service']

  if ($one::puppetdb == true) {
    # Register the node in the puppetdb
    @@one::oned::peer { $::fqdn :
      tag   => $one::params::oneid,
      vtype => $one::vtype,
      ntype => $one::ntype,
    }
  }
}
