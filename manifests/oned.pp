# == Class one::oned
#
# Installs and configures OpenNebula management node
#
# === Author
# ePost Development GmbH
# (c) 2013
#
# Contributors:
# - Martin Alfke
# - Achim Ledermueller (Netways GmbH)
# - Sebastian Saemann (Netways GmbH)
#
# === Parameters
# backend sqlite|mysql - default: sqlite
# Set the OpenNebula backend.
# Set by init.pp
#
# ldap true|false - default: false
# Enable ldap authentication in Sunstone
# Set by init.pp
#
# === Usage
#
# Do not use this class directly. Use class one instead.
# See documentation in one/manifests/init.pp
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::oned (
    $backend    = $one::backend,
    $ldap       = $one::ldap
) {
  include one::prerequisites
  include one::params
  include one::install
  include one::service
  include one::oned::install
  include one::oned::config
  include one::oned::service

  Class['one::prerequisites'] ->
  Class['one::params'] ->
  Class['one::install'] ->
  Class['one::oned::install'] ->
  Class['one::oned::config'] ->
  Class['one::oned::service'] ->
  Class['one::service']

  if ( $backend != 'mysql' and $backend != 'sqlite') {
    fail ( "Class one::oned need to get called with proper DB backend
            (sqlite or mysql). ${backend} is not supported.")
  }
  if ( $ldap != true and $ldap != false) {
      fail( "Class one::oned need to get called with proper ldap value
            (true or false). ${ldap} is not supported.")
  }

  if ($one::puppetdb == true) {
    # Realize all the known nodes
    One::Oned::Peer <<| tag == $one::params::oneid |>> {
      require => Class[one::oned::service],
    }
  }
}
