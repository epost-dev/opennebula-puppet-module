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
    owner   => 'root',
  }
  file { '/usr/lib/one/sunstone':
    ensure  => directory,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0755',
    recurse => true,
  } ->
  file { '/etc/one/sunstone-server.conf':
    ensure  => file,
    content => template('one/sunstone-server.conf.erb'),
    notify  => Service['opennebula-sunstone'],
  } ->
  file { '/etc/one/sunstone-views/admin.yaml':
    ensure => file,
    mode   => '0640',
    source => 'puppet:///modules/one/sunstone-views_admin.yaml',
  } ->
  file { '/etc/one/sunstone-views.yaml':
    ensure  => file,
    mode    => '0640',
    content => template('one/sunstone-views.yaml.erb'),
  }
}
