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
# - Achim Ledermueller (Netways GmbH)
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

  # we only need major version here, so trim off any minor point release(s)
  $one_version_array = split($one_version,"[.]")
  $one_version_short = "${one_version_array[0]}.${one_version_array[1]}"

  case $::osfamily {
    'RedHat': {
      if ( $one_repo_enable == 'true' ) { # lint:ignore:quoted_booleans
        yumrepo { 'opennebula':
          baseurl  => "http://downloads.opennebula.org/repo/${one_version_short}/CentOS/${::operatingsystemmajrelease}/x86_64/",
          descr    => 'OpenNebula',
          enabled  => 1,
          gpgcheck => 0,
        }
      }
    }
    'Debian' : {
      if ($one_repo_enable == 'true') { # lint:ignore:quoted_booleans
        include ::apt
        case $::operatingsystem {
          'Debian': {
            $apt_location="${one_version_short}/Debian/${::operatingsystemmajrelease}"
            $apt_pin='-10'
          }
          'Ubuntu': {
            $apt_location="${one_version_short}/Ubuntu/${::operatingsystemmajrelease}"
            $apt_pin='500'
          }
          default: { fail("Unrecognized operating system ${::operatingsystem}") }
        }

        apt::key { 'one_repo_key':
          key        => '85E16EBF',
          key_source => 'http://downloads.opennebula.org/repo/Debian/repo.key',
        } ->

        apt::source { 'one-official': # lint:ignore:security_apt_no_key
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
  } ->
  user { 'oneadmin':
    ensure     => present,
    uid        => $one::oneuid,
    gid        => $one::onegid,
    home       => '/var/lib/one',
    managehome => true,
    shell      => '/bin/bash',
  }
}
