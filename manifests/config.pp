# Class one::config
#
class one::config (
  $ssh_pub_key  = $one::ssh_pub_key,
  $ssh_priv_key = $one::ssh_priv_key_param,
){

  File {
    ensure  => 'present',
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0600',
  }

  #SSH directory is needed on head and node.
  #
  file { '/var/lib/one/.ssh':
    ensure  => directory,
    mode    => '0700',
    recurse => true,
  }

  file { '/var/lib/one/.ssh/id_dsa':
    content => $ssh_priv_key,
    mode    => '0600',
    require => File['/var/lib/one/.ssh'],
  }

  file { '/var/lib/one/.ssh/id_dsa.pub':
    content => $ssh_pub_key,
    mode    => '0644',
    require => File['/var/lib/one/.ssh'],
  }

  file { '/var/lib/one/.ssh/authorized_keys':
    content => $ssh_pub_key,
  }

  file { '/var/lib/one/.ssh/config':
    source => 'puppet:///modules/one/ssh_one_config',
  }

  file { '/var/lib/one/bin':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0755',
  }

  file { '/var/lib/one/etc':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
  }
}
