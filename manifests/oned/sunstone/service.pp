# == Class one::oned::sunstone::service
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
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::oned::sunstone::service {
  if $one::sunstone_passenger {
      $srv_ensure = stopped
      $srv_enable = false
  } else {
      $srv_ensure = running
      $srv_enable = true
  }
  service { 'opennebula-sunstone':
    ensure  => $srv_ensure,
    enable  => $srv_enable,
    require => Service['opennebula'],
  }
}
