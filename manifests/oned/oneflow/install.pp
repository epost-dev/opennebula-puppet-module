# == Class one::oned::oneflow::install
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
class one::oned::oneflow::install(
  $oned_oneflow_packages = $one::oned_oneflow_packages,
  $package_ensure        = $one::package_ensure,
) inherits one {
  package { $oned_oneflow_packages:
    ensure => $package_ensure,
  }
}
