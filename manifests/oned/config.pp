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
class one::oned::config(
  $ssh_priv_key       = $one::params::ssh_priv_key,
  $ssh_pub_key        = $one::params::ssh_pub_key,
  $hook_scripts_path  = $one::params::hook_scripts_path,
  ) {
  file { '/etc/one/oned.conf':
    content => template('one/oned.conf.erb'),
    owner   => 'root',
    group   => 'oneadmin',
    mode    => '0640',
  }
  file { '/usr/share/one':
    ensure => 'directory',
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0755',
  }
  file { '/usr/share/one/hooks':
    ensure  => 'directory',
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0750',
    recurse => true,
    source  => $hook_scripts_path,
  }
  file { '/var/lib/one/.ssh/id_dsa':
    content => $ssh_priv_key,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0600',
  }
  file { '/var/lib/one/.ssh/id_dsa.pub':
    content => $ssh_pub_key,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0644',
  }
}
