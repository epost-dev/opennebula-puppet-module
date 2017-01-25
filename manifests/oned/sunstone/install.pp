# == Class one::oned::sunstone::install
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
class one::oned::sunstone::install (
  $oned_sunstone_packages = $one::oned_sunstone_packages,
  $package_ensure         = $one::package_ensure,
){
  package { $oned_sunstone_packages:
    ensure => $package_ensure,
  }
}
