# == Class one::oned::sunstone::config
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
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::oned::sunstone::config {
  file { '/usr/lib/one/sunstone':
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0644',
    recurse => true,
  }

  file { '/etc/one/sunstone-server.conf':
    content => template('one/sunstone-server.conf.erb'),
    owner   => 'root',
    group   => 'oneadmin',
    mode    => '0644',
  }
  file { '/etc/one/sunstone-views/admin.yaml':
    source => 'puppet:///modules/one/sunstone-views_admin.yaml',
    owner  => 'root',
    group  => 'oneadmin',
    mode   => '0640',
  }
  file { '/etc/one/sunstone-views.yaml':
    ensure  => file,
    owner   => 'root',
    group   => 'oneadmin',
    mode    => '0640',
    source  => 'puppet:///modules/one/sunstone-views.yaml',
    require => File['/etc/one/sunstone-server.conf'],
  }
}
