#
# == Class one::prerequisites
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
# - Achim Ledermüller (Netways GmbH)
# - Sebastian Saemann (Netways GmbH)
# - Thomas Fricke (Endocode AG)
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::prerequisites {
  case $::osfamily {
    'RedHat': {
      if ( $one::one_repo_enable == 'true' ) {
        yumrepo { 'opennebula':
          baseurl  => "http://downloads.opennebula.org/repo/4.10/CentOS/${::operatingsystemmajrelease}/x86_64/",
          descr    => 'OpenNebula',
          enabled  => 1,
          gpgcheck => 0,
        }
      }
    }
    'Debian' : {
      if ($one::one_repo_enable == 'true') {
        include ::apt
        case $::operatingsystem {
          'Debian': {
            $apt_location="4.10/Debian/${::operatingsystemmajrelease}"
            $apt_pin='-10'
          }
          'Ubuntu': {
            $apt_location="4.10/Ubuntu/${::operatingsystemmajrelease}"
            $apt_pin='500'
          }
          default: { fail("Unrecognized operating system ${::operatingsystem}") }
        }

        apt::key { 'one_repo_key':
          key        => '85E16EBF',
          key_source => 'http://downloads.opennebula.org/repo/Debian/repo.key',
        } ->

        apt::source { 'one-official':
          location          => "http://downloads.opennebula.org/repo/${apt_location}",
          release           => 'stable',
          repos             => 'opennebula',
          required_packages => 'debian-keyring debian-archive-keyring',
          pin               => $apt_pin,
          include_src       => false,
        }
      }
    }
    default: {
      notice('We use opennebula from default OS repositories.')
    }
  }
  group { 'oneadmin':
    ensure => present,
    gid    => $one::onegid,
  }
  user { 'oneadmin':
    ensure     => present,
    uid        => $one::oneuid,
    gid        => $one::onegid,
    home       => '/var/lib/one',
    managehome => true,
    shell      => '/bin/bash'
  }
}
