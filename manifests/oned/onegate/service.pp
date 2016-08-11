# == Class one::oned::onegate::service
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
class one::oned::onegate::service {

  if ($one::ha_setup) {
    $onegate_enable = false
    $onegate_ensure = undef
  } else {
    $onegate_enable = true
    $onegate_ensure = running
  }

  service {'opennebula-gate':
    ensure  => $onegate_ensure,
    enable  => $onegate_enable,
    require => Service['opennebula'],
  }
}
