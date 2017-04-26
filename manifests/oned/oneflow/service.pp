# == Class one::oned::oneflow::service
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
# - Matthias Schmitz
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::oned::oneflow::service {

  if ($one::ha_setup) {
    $oneflow_enable = false
    $oneflow_ensure = undef
  } else {
    $oneflow_enable = true
    $oneflow_ensure = running
  }

  service {'opennebula-flow':
    ensure  => $oneflow_ensure,
    enable  => $oneflow_enable,
    require => Service['opennebula'],
  }
}
