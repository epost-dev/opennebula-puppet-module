# Class one::config
#
class one::config (
  $ssh_pub_key  = $one::params::ssh_pub_key,
){
  #SSH directory is needed on head and node.
  #
  file { '/var/lib/one/.ssh':
    ensure  => directory,
    recurse => true,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0700',
  }

  file { '/var/lib/one/.ssh/authorized_keys':
    content => $ssh_pub_key,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0600',
  }

  file { '/var/lib/one/.ssh/config':
    source => 'puppet:///modules/one/ssh_one_config',
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0600',
  }

}
