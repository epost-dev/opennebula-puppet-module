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
# - Achim Ledermueller (Netways GmbH)
# - Sebastian Saemann (Netways GmbH)
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::oned::sunstone::config (
  $listen_ip          = $one::sunstone_listen_ip,
  $enable_support     = $one::enable_support,
  $enable_marketplace = $one::enable_marketplace,
  $tmpdir             = $one::sunstone_tmpdir,
){
  File {
    ensure  => 'file',
    owner   => 'root',
    group   => 'oneadmin',
  }
  file { '/usr/lib/one/sunstone':
    ensure  => 'directory',
    owner   => 'oneadmin',
    recurse => true,
  }
  file { '/etc/one/sunstone-server.conf':
    content => template('one/sunstone-server.conf.erb'),
    notify  => Service['opennebula-sunstone'],
  }
  file { '/etc/one/sunstone-views/admin.yaml':
    source => 'puppet:///modules/one/sunstone-views_admin.yaml',
    mode   => '0640',
  }
  file { '/etc/one/sunstone-views.yaml':
    mode    => '0640',
    content => template('one/sunstone-views.yaml.erb'),
    require => File['/etc/one/sunstone-server.conf'],
  }
}
