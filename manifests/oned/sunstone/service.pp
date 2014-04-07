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
  service { 'opennebula-sunstone':
    ensure => running,
    enable => true,
    require=> Service['opennebula'],
  }
}
