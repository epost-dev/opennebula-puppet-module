# Class one::install
#
# packages needed by both (compute node and head)
#
class one::install {
  package { $one::params::dbus_pkg:
    ensure  => present,
    require => Class['one::prerequisites'],
  }

  #SSH directory is needed on head and node.
  #
  file { '/var/lib/one':
    owner   => 'oneadmin',
    group   => 'oneadmin',
  }

  file { '/var/lib/one/.ssh':
    ensure  => directory,
    recurse => true,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0700',
  }

}
