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
  $oned_db            = $one::params::oned_db,
  $oned_db_user       = $one::params::oned_db_user,
  $oned_db_password   = $one::params::oned_db_password,
  $oned_db_host       = $one::params::oned_db_host,
  $backup_script_path = $one::params::backup_script_path,
  $backup_opts        = $one::params::backup_opts,
  $backup_dir         = $one::params::backup_dir,
  $backup_db          = $one::params::backup_db,
  $backup_db_user     = $one::params::backup_db_user,
  $backup_db_password = $one::params::backup_db_password,
  $backup_db_host     = $one::params::backup_db_host,
  $backup_intervall   = $one::params::backup_intervall,
  $backup_keep        = $one::params::backup_keep,
  $puppet_hook        = $one::params::puppet_hook
  ) {

  File {
    owner  => 'oneadmin',
    group  => 'oneadmin',
  }

  file { '/etc/one/oned.conf':
    content => template('one/oned.conf.erb'),
    owner   => 'root',
    mode    => '0640',
  }

  file { '/usr/share/one':
    ensure => 'directory',
    mode   => '0755',
  }

  file { '/usr/share/one/hooks':
    ensure  => 'directory',
    ignore  => 'tests/*',
    mode    => '0750',
    recurse => 'true',
    purge   => 'true',
    force   => 'true',
    source  => $hook_scripts_path,
  }

  file { '/var/lib/one/.ssh/id_dsa':
    content => $ssh_priv_key,
    mode    => '0600',
  }

  file { '/var/lib/one/.ssh/id_dsa.pub':
    content => $ssh_pub_key,
    mode    => '0644',
  }

  if ($one::backend == 'mysql') {
    file { $backup_dir:
      ensure => 'directory',
      mode   => '0700'
    }

    file { $backup_script_path:
      ensure  => present,
      mode    => '0700',
      content => template('one/one_db_backup.sh.erb'),
    }

    cron { 'one_db_backup':
      command => $backup_script_path,
      user    => $backup_db_user,
      target  => $backup_db_user,
      minute  => $backup_intervall,
    }
  }
}
