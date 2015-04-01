# == Class one::oned::sunstone
#
# Installation and Configuration of OpenNebula
# http://opennebula.org/
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
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::oned::sunstone (
  $ldap = $one::oned::ldap
) {
  include one::prerequisites
  include one::oned::sunstone::install
  include one::oned::sunstone::config
  include one::oned::sunstone::service

  Class['one::prerequisites'] ->
  Class['one::oned::sunstone::install'] ->
  Class['one::oned::sunstone::config'] ~>
  Class['one::oned::sunstone::service']

  if $ldap {
    include one::oned::sunstone::ldap
    Class['one::oned::sunstone::config'] ->
    Class['one::oned::sunstone::ldap']
  }
}
