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
  $hook_scripts_path           = $one::hook_scripts_path,
  $hook_scripts                = $one::hook_scripts,
  $vm_hook_scripts             = $one::vm_hook_scripts,
  $host_hook_scripts           = $one::host_hook_scripts,
  $inherit_datastore_attrs     = $one::inherit_datastore_attrs,
  $oned_port                   = $one::oned_port,
  $oned_db                     = $one::oned_db,
  $oned_db_user                = $one::oned_db_user,
  $oned_db_password            = $one::oned_db_password,
  $oned_db_host                = $one::oned_db_host,
  $oned_vm_submit_on_hold      = $one::oned_vm_submit_on_hold,
  $backup_script_path          = $one::backup_script_path,
  $backup_opts                 = $one::backup_opts,
  $backup_dir                  = $one::backup_dir,
  $backup_db                   = $one::backup_db,
  $backup_db_user              = $one::backup_db_user,
  $backup_db_password          = $one::backup_db_password,
  $backup_db_host              = $one::backup_db_host,
  $backup_intervall            = $one::backup_intervall,
  $backup_keep                 = $one::backup_keep,
  $debug_level                 = $one::debug_level,
  $backend                     = $one::backend,
  $sched_interval              = $one::sched_interval,
  $sched_max_vm                = $one::sched_max_vm,
  $sched_max_dispatch          = $one::sched_max_dispatch,
  $sched_max_host              = $one::sched_max_host,
  $sched_live_rescheds         = $one::sched_live_rescheds,
  $sched_default_policy        = $one::sched_default_policy,
  $sched_default_rank          = $one::sched_default_rank,
  $sched_default_ds_policy     = $one::sched_default_ds_policy,
  $sched_default_ds_rank       = $one::sched_default_ds_rank,
  $sched_log_system            = $one::sched_log_system,
  $sched_log_debug_level       = $one::sched_log_debug_level,
  $kvm_driver_emulator         = $one::kvm_driver_emulator,
  $kvm_driver_nic_attrs        = $one::kvm_driver_nic_attrs,
  $datastore_capacity_check    = $one::datastore_capacity_check,
  $default_image_type          = $one::default_image_type,
  $default_device_prefix       = $one::default_device_prefix,
  $default_cdrom_device_prefix = $one::default_cdrom_device_prefix,
) {

  if ! member(['YES', 'NO'], $oned_vm_submit_on_hold) {
    fail("oned_vm_submit_on_hold must be one of 'YES' or 'NO'. Actual value: ${oned_vm_submit_on_hold}")
  }

  if ! is_integer($sched_interval) {
    fail("sched_interval must be of type integer. Actual value: ${sched_interval}" )
  }
  if ! is_integer($sched_max_vm) {
    fail("sched_max_vm must be of type integer. Actual value: ${sched_max_vm}" )
  }
  if ! is_integer($sched_max_dispatch) {
    fail("sched_max_dispatch must be of type integer. Actual value: ${sched_max_dispatch}" )
  }
  if ! is_integer($sched_max_host) {
    fail("sched_max_host must be of type integer. Actual value: ${sched_max_host}" )
  }
  if ! is_integer($sched_live_rescheds) {
    fail("sched_live_rescheds must be of type integer. Actual value: ${sched_live_rescheds}" )
  }
  if ! is_integer($sched_default_policy) {
    fail("sched_default_policy must be of type integer. Actual value: ${sched_default_policy}" )
  }
  validate_string($sched_default_rank)
  if ! is_integer($sched_default_ds_policy) {
    fail("sched_default_ds_policy must be of type integer. Actual value: ${sched_default_ds_policy}" )
  }
  validate_string($sched_default_ds_rank)
  if ! member(['file', 'syslog'], $sched_log_system) {
    fail("sched_log_system must be one of 'file' or 'syslog'. Actual value: ${sched_log_system}")
  }
  if ! is_integer($sched_log_debug_level) {
    fail("sched_log_debug_level must be of type integer. Actual value: ${sched_log_debug_level}" )
  }


  File {
    owner  => 'oneadmin',
    group  => 'oneadmin',
  }

  file { '/etc/one/oned.conf':
    ensure  => file,
    owner   => 'root',
    mode    => '0640',
    content => template('one/oned.conf.erb'),
  }

  file { '/etc/one/sched.conf':
    ensure  => 'file',
    owner   => 'root',
    mode    => '0640',
    content => template('one/sched.conf.erb'),
  } ->

  file { '/usr/share/one':
    ensure => directory,
    mode   => '0755',
  } ->

  file { '/usr/share/one/hooks':
    ensure  => directory,
    ignore  => 'tests/*',
    mode    => '0750',
    recurse => true,
    purge   => true,
    force   => true,
    source  => $hook_scripts_path,
  }

  if $kvm_driver_emulator != 'undef' {
    ini_setting{ 'set_kvm_driver_emulator':
      ensure  => present,
      section => '',
      path    => '/etc/one/vmm_exec/vmm_exec_kvm.conf',
      setting => 'EMULATOR',
      value   => $kvm_driver_emulator,
    }
  }

  if $kvm_driver_nic_attrs != 'undef' {
    ini_setting{ 'set_kvm_driver_nic':
      ensure  => present,
      section => '',
      path    => '/etc/one/vmm_exec/vmm_exec_kvm.conf',
      setting => 'NIC',
      value   => $kvm_driver_nic_attrs,
    }
  }

  if ($backend == 'mysql') {

    file { $backup_dir:
      ensure => directory,
      mode   => '0700',
    } ->

    file { $backup_script_path:
      ensure  => file,
      mode    => '0700',
      content => template('one/one_db_backup.sh.erb'),
    } ->

    cron { 'one_db_backup':
      command => $backup_script_path,
      user    => $backup_db_user,
      target  => $backup_db_user,
      minute  => $backup_intervall,
    }
  }
}
