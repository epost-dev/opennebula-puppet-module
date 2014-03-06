# Class one::install
#
# packages needed by both (compute node and head)
#
class one::install {
  package { $one::params::dbus_pkg:
    ensure  => present,
    require => Class['one::prerequisites'],
  }

  file { '/var/lib/one':
    ensure  => 'directory',
    owner   => 'oneadmin',
    group   => 'oneadmin',
  }
}
