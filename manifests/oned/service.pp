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
class one::oned::service (
  $ha_setup = $one::ha_setup,
){
  if ($ha_setup) {
    $oned_enable = false
    $oned_ensure = undef
  } else {
    $oned_enable = true
    $oned_ensure = running
  }
  service {'opennebula':
    ensure    => $oned_ensure,
    hasstatus => true,
    enable    => $oned_enable,
    require   => Class['one::oned::install'],
    subscribe => Class['one::oned::config'],
  }
}
