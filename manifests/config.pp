# Class one::config
#
class one::config (
  $ssh_pub_key  = $one::params::ssh_pub_key,
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

  file { '/var/lib/one/.ssh/authorized_keys':
    content => $ssh_pub_key,
  }

  file { '/var/lib/one/.ssh/config':
    source => 'puppet:///modules/one/ssh_one_config',
  }
}
