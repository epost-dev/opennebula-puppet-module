# == Class one::oned::install
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
class one::oned::install {
  package { $one::rubygems :
    ensure   => latest,
    provider => gem,
    require  => Class['one::prerequisites'],
  }
  package { $one::oned_packages :
    ensure  => latest,
    require => Class['one::prerequisites'],
  }

  if ($one::hook_scripts_pkgs) {
    package { $one::hook_scripts_pkgs :
      ensure  => latest,
      require => Class['one::prerequisites'],
    }
  }
}
