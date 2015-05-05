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
class one::prerequisites(
  $one_repo_enable  = $one::one_repo_enable,
  $one_version      = $one::one_version,
) {
  case $::osfamily {
    'RedHat': {
      if ( $one_repo_enable == 'true' ) {
        yumrepo { 'opennebula':
          baseurl  => "http://downloads.opennebula.org/repo/${one_version}/CentOS/${::operatingsystemmajrelease}/x86_64/",
          descr    => 'OpenNebula',
          enabled  => 1,
          gpgcheck => 0,
        }
      }
    }
    'Debian' : {
      if ($one_repo_enable == 'true') {
        include ::apt
        case $::operatingsystem {
          'Debian': {
            $apt_location="${one_version}/Debian/${::operatingsystemmajrelease}"
            $apt_pin='-10'
          }
          'Ubuntu': {
            $apt_location="${one_version}/Ubuntu/${::operatingsystemmajrelease}"
            $apt_pin='500'
          }
          default: { fail("Unrecognized operating system ${::operatingsystem}") }
        }

        apt::key { 'one_repo_key':
          id        => '85E16EBF',
          source    => 'http://downloads.opennebula.org/repo/Debian/repo.key',
        } ->
        
        apt::source { 'one-official':
          location          => "http://downloads.opennebula.org/repo/${apt_location}",
          release           => 'stable',
          repos             => 'opennebula',
          pin               => $apt_pin,
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
  } ->
  user { 'oneadmin':
    ensure     => present,
    uid        => $one::oneuid,
    gid        => $one::onegid,
    home       => '/var/lib/one',
    managehome => true,
    shell      => '/bin/bash'
  }
}
