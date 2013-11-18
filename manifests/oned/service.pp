# == Class one::oned::service
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
class one::oned::service {
  service {'opennebula':
    ensure    => $one::params::oned_ensure,
    hasstatus => true,
    enable    => $one::params::oned_enable,
    require   => Class['one::oned::install'],
    subscribe => Class['one::oned::config'],
  }
}
