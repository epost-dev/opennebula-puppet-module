# == Class one::oned::config
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
class one::oned::config {
  file { '/etc/one/oned.conf':
    content => template('one/oned.conf.erb'),
    owner   => 'root',
    group   => 'oneadmin',
    mode    => '0640',
  }
  file { '/usr/share/one/hooks':
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0750',
    recurse => true,
    source  => 'puppet:///modules/one/hookscripts',
  }
  file { '/var/lib/one':
    owner   => 'oneadmin',
    group   => 'oneadmin',
    recurse => true,
  }
}
