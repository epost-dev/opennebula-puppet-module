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
            if ( $one::params::one_repo_enable == true ) {
                yumrepo { 'opennebula':
                    baseurl  => 'http://opennebula.org/repo/CentOS/6/stable/$basearch/',
                    descr    => 'OpenNebula',
                    enabled  => 1,
                    gpgcheck => 0,
                }
            }
        }
        'Debian' : {
      if ($one::params::one_repo_enable == true) {
        class { apt: }

        apt::source { 'one-official':
          location          => "http://downloads.opennebula.org/repo/Debian/${lsbmajdistrelease}",
          release           => 'stable',
          repos             => 'opennebula',
          required_packages => 'debian-keyring debian-archive-keyring',
          pin               => '-10',
          include_src       => false,
          require           => Apt::Key['one_repo_key'],
        }

        apt::key { 'one_repo_key':
          key        => '85E16EBF',
          key_source => 'http://downloads.opennebula.org/repo/Debian/repo.key',
        }
      }
    }
        default: {
            notice('We use opennebula from default OS repositories.')
        }
    }
    group { 'oneadmin':
        ensure => present,
        gid    => $one::params::onegid,
    }
    user { 'oneadmin':
        ensure      => present,
        uid         => $one::params::oneuid,
        gid         => $one::params::onegid,
        home        => '/var/lib/one',
        managehome  => true,
        shell       => '/bin/bash'
    }
}
