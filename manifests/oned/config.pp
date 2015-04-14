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
  $hook_scripts_path      = $one::hook_scripts_path,
  $hook_scripts           = $one::hook_scripts,
  $vm_hook_scripts        = $one::vm_hook_scripts,
  $host_hook_scripts      = $one::host_hook_scripts,
  $oned_db                = $one::oned_db,
  $oned_db_user           = $one::oned_db_user,
  $oned_db_password       = $one::oned_db_password,
  $oned_db_host           = $one::oned_db_host,
  $oned_vm_submit_on_hold = $one::oned_vm_submit_on_hold,
  $backup_script_path     = $one::backup_script_path,
  $backup_opts            = $one::backup_opts,
  $backup_dir             = $one::backup_dir,
  $backup_db              = $one::backup_db,
  $backup_db_user         = $one::backup_db_user,
  $backup_db_password     = $one::backup_db_password,
  $backup_db_host         = $one::backup_db_host,
  $backup_intervall       = $one::backup_intervall,
  $backup_keep            = $one::backup_keep,
  $debug_level            = $one::debug_level,
  $backend                = $one::backend,
  ) {

  if ! member(['YES', 'NO'], $oned_vm_submit_on_hold) {
    fail("oned_vm_submit_on_hold must be one of 'YES' or 'NO'. Actual value: ${oned_vm_submit_on_hold}")
  }

  File {
    owner  => 'oneadmin',
    group  => 'oneadmin',
  }

  file { '/etc/one/oned.conf':
    ensure  => 'file',
    owner   => 'root',
    mode    => '0640',
    content => template('one/oned.conf.erb'),
  }

  file { '/usr/share/one':
    ensure => 'directory',
    mode   => '0755',
  }

  file { '/usr/share/one/hooks':
    ensure  => 'directory',
    ignore  => 'tests/*',
    mode    => '0750',
    recurse => true,
    purge   => true,
    force   => true,
    source  => $hook_scripts_path,
  }

  if ($backend == 'mysql') {
    file { $backup_dir:
      ensure => 'directory',
      mode   => '0700'
    }

    file { $backup_script_path:
      ensure  => 'file',
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
