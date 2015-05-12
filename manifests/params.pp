# == Class one::params
#
# Installation and Configuration of OpenNebula
# http://opennebula.org/
#
# Sets required variables
# read some data from hiera, but also has defaults.
#
# === Author
# ePost Development GmbH
# (c) 2013
#
# Contributors:
# - Martin Alfke
# - Achim Ledermüller (Netways GmbH)
# - Sebastian Saemann (Netways GmbH)
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::params (
) {

  # OpenNebula parameters

  $oned_db          = hiera('one::oned::db', 'oned')
  $oned_db_user     = hiera('one::oned::db_user', 'oned')
  $oned_db_password = hiera('one::oned::db_password', 'oned')
  $oned_db_host     = hiera('one::oned::db_host', 'localhost')
  # ldap stuff (optional needs one::oned::ldap in hiera set to true)
  $oned_ldap_host = hiera('one::oned::ldap_host','ldap')
  $oned_ldap_port = hiera('one::oned::ldap_port','636')
  $oned_ldap_base = hiera('one::oned::ldap_base','dc=example,dc=com')
  # $oned_ldap_user: can be empty if anonymous query is possible
  $oned_ldap_user = hiera('one::oned::ldap_user', 'cn=ldap_query,ou=user,dc=example,dc=com')
  $oned_ldap_pass = hiera('one::oned::ldap_pass','default_password')
  # $oned_ldap_group: can be empty, can be set to a group to restrict access to sunstone
  $oned_ldap_group = hiera( 'one::oned::ldap_group', 'undef')
  # $oned_ldap_user_field: defaults to uid, can be set to the field, that holds the username in ldap
  $oned_ldap_user_field = hiera('one::oned::ldap_user_field','undef')
  # $oned_ldap_group_field: default to member, can be set to the filed that holds the groupname
  $oned_ldap_group_field = hiera('one::oned::ldap_group_field', 'undef')
  # $oned_ldap_user_group_field: default to dn, can be set to the user field that is in the group group_field
  $oned_ldap_user_group_field = hiera('one::oned::ldap_user_group_field','undef')
  # should we enable opennebula repos?
  $one_repo_enable = hiera('one::enable_opennebula_repo', 'true' )
  # should VM_SUBMIT_ON_HOLD be enabled in oned.conf?
  $oned_vm_submit_on_hold    = hiera('one::oned::vm_submit_on_hold', 'NO')

  # SSH Key
  $ssh_priv_key_param        = hiera('one::head::ssh_priv_key',undef)
  $ssh_pub_key               = hiera('one::head::ssh_pub_key',undef)

  # OpenNebula XMLRPC tuning parameters
  $xmlrpc_maxconn            = hiera('one::oned::xmlrpc_maxconn', '15')
  $xmlrpc_maxconn_backlog    = hiera('one::oned::xmlrpc_maxconn_backlog', '15')
  $xmlrpc_keepalive_timeout  = hiera('one::oned::xmlrpc_keepalive_timeout', '15')
  $xmlrpc_keepalive_max_conn = hiera('one::oned::xmlrpc_keepalive_max_conn', '30')
  $xmlrpc_timeout            = hiera('one::oned::xmlrpc_timeout', '15')

  # Sunstone configuration parameters
  $sunstone_listen_ip        = hiera('one::oned::sunstone_listen_ip', '127.0.0.1')
  $enable_support            = hiera('one::oned::enable_support', 'yes')
  $enable_marketplace        = hiera('one::oned::enable_marketplace', 'yes')
  $sunstone_tmpdir           = hiera('one::oned::sunstone_tmpdir', '/var/tmp')

  # generic params for nodes and oned
  $oneuid = '9869'
  $onegid = '9869'

  # OpenNebula monitoring parameters
  $monitoring_interval = hiera('one::oned::monitoring_interval', '60')
  $monitoring_threads  = hiera('one::oned::monitoring_threads', '50')
  $information_collector_interval = hiera('one::oned::information_collector_interval', '20')

  $http_proxy = hiera('one::oned::http_proxy', '')

  #
  # hook script installation
  #
  # Alternative 1: Put the scripts into a puppet module.
  # Allows it to be overwritten by custom puppet profile
  # Should be the path to the folder which should be the source for the hookscripts on the puppetmaster
  # Default is a folder with an empty sample_hook.py
  $hook_scripts_path = hiera('one::head::hook_script_path', 'puppet:///modules/one/hookscripts')

  # Alternative 2: Define package(s) which install the hook scripts.
  # This should be the preferred way.
  $hook_scripts_pkgs = hiera('one::head::hook_script_pkgs', undef)

  # Configuration for VM_HOOK and HOST_HOOK in oned.conf.
  # Activate and configure the hook scripts delivered via $hook_scripts_path or $hook_scripts_pkgs.
  $hook_scripts = hiera('one::head::hook_scripts', undef)

  # Todo: Use Serviceip from HA-Setup if ha enabled.
  $oned_onegate_ip = hiera('one::oned::onegate::ip', $::ipaddress)

  # E-POST imaginator parameters
  $kickstart_network         = hiera ('one::node::kickstart::network', undef)
  $kickstart_partition       = hiera ('one::node::kickstart::partition', undef)
  $kickstart_rootpw          = hiera ('one::node::kickstart::rootpw', undef)
  $kickstart_data            = hiera ('one::node::kickstart::data', undef)
  $kickstart_tmpl            = hiera ('one::node::kickstart::kickstart_tmpl', 'one/kickstart.ks.erb')

  $preseed_data              = hiera ('one::node::preseed::data', {})
  $preseed_debian_mirror_url = hiera ('one::node::preseed::debian_mirror_url',
                                      'http://ftp.debian.org/debian')
  $preseed_ohd_deb_repo      = hiera ('one::node::preseed::ohd_deb_repo', undef)
  $preseed_tmpl              = hiera ('one::node::preseed::preseed_tmpl', 'one/preseed.cfg.erb')

  # OpenNebula DB backup parameters
  $backup_script_path        = hiera ('one::oned::backup::script_path', '/var/lib/one/bin/one_db_backup.sh')
  $backup_dir                = hiera ('one::oned::backup::dir', '/srv/backup')
  $backup_opts               = hiera ('one::oned::backup::opts', '-C -q -e')
  $backup_db                 = hiera ('one::oned::backup::db', 'oned')
  $backup_db_user            = hiera ('one::oned::backup::db_user', 'onebackup')
  $backup_db_password        = hiera ('one::oned::backup::db_password', 'onebackup')
  $backup_db_host            = hiera ('one::oned::backup::db_host', 'localhost')
  $backup_intervall          = hiera ('one::oned::backup::intervall', '*/10')
  $backup_keep               = hiera ('one::oned::backup::keep', '-mtime +15')

  # OpenNebula Scheduler parameters
  $sched_interval            = hiera ('one::oned::sched::sched_interval', 30)
  $sched_max_vm              = hiera ('one::oned::sched::max_vm', 5000)
  $sched_max_dispatch        = hiera ('one::oned::sched::max_dispatch', 30)
  $sched_max_host            = hiera ('one::oned::sched::max_host', 1)
  $sched_live_rescheds       = hiera ('one::oned::sched::live_rescheds', 0)
  $sched_default_policy      = hiera ('one::oned::sched::default_policy', 1)
  $sched_default_rank        = hiera ('one::oned::sched::default_rank', '- (RUNNING_VMS * 50  + FREE_CPU)')
  $sched_default_ds_policy   = hiera ('one::oned::sched::default_ds_policy', 1)
  $sched_default_ds_rank     = hiera ('one::oned::sched::default_ds_rank', '')
  $sched_log_system          = hiera ('one::oned::sched::log_system', 'file')
  $sched_log_debug_level     = hiera ('one::oned::sched::log_debug_level', 3)
  
  # Data Validation

  # the priv key is mandatory on the head.
  validate_string($ssh_pub_key)
  if (!$one::node) {
    validate_string($ssh_priv_key_param)
    $ssh_priv_key = $ssh_priv_key_param
  }

  # ensure xmlrpctuning is in string
  validate_string($xmlrpc_maxconn, $xmlrpc_maxconn_backlog, $xmlrpc_keepalive_timeout, $xmlrpc_keepalive_max_conn, $xmlrpc_timeout)

  if ($hook_scripts_pkgs) {
    validate_array($hook_scripts_pkgs)
  }

  if ($hook_scripts) {
    validate_hash($hook_scripts)
    $vm_hook_scripts=$hook_scripts['VM']

    if ($vm_hook_scripts) {
      validate_hash($vm_hook_scripts)
    }

    $host_hook_scripts=$hook_scripts['HOST']
    if ($host_hook_scripts) {
      validate_hash($host_hook_scripts)
    }
  }

  # OS specific params for nodes
  case $::osfamily {
    'RedHat': {
      if $::operatingsystemmajrelease== '7' {
        $node_packages = ['opennebula-node-kvm',
                          'sudo'
                          ]
      } else {
        $node_packages = ['opennebula-node-kvm',
                          'sudo',
                          'python-virtinst'
                          ]
      }
      $oned_packages   = ['opennebula', 'opennebula-server', 'opennebula-ruby']
      $dbus_srv        = 'messagebus'
      $dbus_pkg        = 'dbus'
      $oned_sunstone_packages = 'opennebula-sunstone'
      $oned_sunstone_ldap_pkg = ['ruby-ldap','rubygem-net-ldap']
      # params for oneflow (optional, needs one::oneflow set to true)
      $oned_oneflow_packages = ['opennebula-flow',
                                'rubygem-treetop',
                                'rubygem-polyglot'
                                ]
      # params for onegate (optional, needs one::onegate set to true)
      $oned_onegate_packages = ['opennebula-gate', 'rubygem-parse-cron']
      $libvirtd_srv = 'libvirtd'
      $libvirtd_cfg = '/etc/sysconfig/libvirtd'
      $libvirtd_source = 'puppet:///modules/one/libvirtd.sysconfig'
      $use_gems           = str2bool(hiera('one::oned::install::use_gems', 'true'))
      $rubygems           = ['builder', 'sinatra']
      $rubygems_rpm       = ['rubygem-builder', 'rubygem-sinatra']
    }
    'Debian': {
      $use_gems        = true
      $node_packages   = ['opennebula-node',
                          'sudo',
                          'virtinst'
                          ]
      $rubygems       = ['parse-cron']
      $oned_packages   = ['opennebula', 'opennebula-tools', 'ruby-opennebula']
      $dbus_srv        = 'dbus'
      $dbus_pkg        = 'dbus'
      $oned_sunstone_packages = 'opennebula-sunstone'
      $oned_sunstone_ldap_pkg = ['ruby-ldap','ruby-net-ldap']
      $oned_oneflow_packages = ['opennebula-flow',
                                'ruby-treetop',
                                'ruby-polyglot'
                                ]
      $oned_onegate_packages = ['opennebula-gate']
      $libvirtd_srv = 'libvirt-bin'
      $libvirtd_cfg = '/etc/default/libvirt-bin'
      $libvirtd_source = 'puppet:///modules/one/libvirt-bin.debian'
    }
    default: {
      fail("Your OS - ${::osfamily} - is not yet supported.
            Please add required functionality to params.pp")
    }
  }

}
