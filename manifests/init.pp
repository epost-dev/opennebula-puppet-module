# == Class one
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
# === Parameters
#
# $oneid <string> - default to one-cloud
#   set the id of the cloud
#
# $node true|false - default true
#  defines whether the host is node (virtualization host/worker)
#
# $vtype - default kvm
#  set virtualization type for opennebula compute node
#  supported vtypes:
#   - kvm
#   - xen3
#   - xen4
#   - vmware
#   - ec2
#   - dummy
#   - qemu
#
# $ntype - default 802.1Q
#  set network type for opennebula compute node
#  supported tyes
#   - 802.1Q
#   - ebtables
#   - firewall
#   - ovswitch
#   - vmware
#
# $oned true|false - default false
#   defines whether OpenNebula-Daemon should be installed.
#   OpenNebula-Daemon needs to run on the system where you want to manage your
#   OpenNebula systems.
#   You need exactly one OpenNebula Daemon in your infrastructure.
#
# $backend sqlite|mysql - default to sqlite
#   defines which backend should be used
#   supports sqlite or mysql
#   does not install mysql server, only uses information from params.pp
#
# $sunstone true|false - default false
#   defines where the Sunstone Webinterface should be installed.
#   Sunstone Webinterface is fully optional.
#
# $sunstone_passenger - default false
#   defines whether Sunstone Webinterface should be started by apache instead of webrick
#   needs separate apache config
#   only used if $sunstone is set to true
#
# $ldap true|false - default false
#   defines whether sunstone authentication to ldap should be enabled
#   ldap is fully optional
#
# $ha_setup true | false - default false
#   defines whether the oned should be run on boot
#
# $oneflow true|false - default false
#   defines whether the oneflow service should be installed
#
# $puppetdb true|false - default false
#   defines to use puppetDB to discover peer nodes
#
# $debug_level - default 0
#   defines the debug level under which oned and sunstone are running
#
# === Usage
#
# install compute node
# class { one: }
#
# install opennebula management node (without sunstone webinterface)
# class { one: oned => true }
#
# install opennebula management node with sunstone webinterface
# class { one:
#   oned => true,
#   sunstone => true,
# }
#
# install opennebula sunstone webinterface only
# class { one: sunstone => true }
#
# installation of optional oneflow and onegate requires oned.
# class { one:
#   oned => true,
#   oneflow => true,
#   onegate => true,
# }
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one (
            $oneid              = 'one-cloud',
            $node               = true,
            $vtype              = 'kvm',
            $ntype              = '802.1Q',
            $oned               = false,
            $sunstone           = false,
            $sunstone_passenger = false,
            $ldap               = false,
            $oneflow            = false,
            $onegate            = false,
            $backend            = 'sqlite',
            $ha_setup           = false,
            $puppetdb           = false,
            $debug_level        = '0',
            $oned_db                        = $one::params::oned_db,
            $oned_db_user                   = $one::params::oned_db_user,
            $oned_db_password               = $one::params::oned_db_password,
            $oned_db_host                   = $one::params::oned_db_host,
            $oned_ldap_host                 = $one::params::oned_ldap_host,
            $oned_ldap_port                 = $one::params::oned_ldap_port,
            $oned_ldap_base                 = $one::params::oned_ldap_base,
            $oned_ldap_user                 = $one::params::oned_ldap_user,
            $oned_ldap_pass                 = $one::params::oned_ldap_pass,
            $oned_ldap_group                = $one::params::oned_ldap_group,
            $oned_ldap_user_field           = $one::params::oned_ldap_user_field,
            $oned_ldap_group_field          = $one::params::oned_ldap_group_field,
            $oned_ldap_user_group_field     = $one::params::oned_ldap_user_group_field,
            $one_repo_enable                = $one::params::one_repo_enable,
            $ssh_priv_key_param             = $one::params::ssh_priv_key_param,
            $ssh_pub_key                    = $one::params::ssh_pub_key,
            $xmlrpc_maxconn                 = $one::params::xmlrpc_maxconn,
            $xmlrpc_maxconn_backlog         = $one::params::xmlrpc_maxconn_backlog,
            $xmlrpc_keepalive_timeout       = $one::params::xmlrpc_keepalive_timeout,
            $xmlrpc_keepalive_max_conn      = $one::params::xmlrpc_keepalive_max_conn,
            $xmlrpc_timeout                 = $one::params::xmlrpc_timeout,
            $sunstone_listen_ip             = $one::params::sunstone_listen_ip,
            $enable_support                 = $one::params::enable_support,
            $enable_marketplace             = $one::params::enable_marketplace,
            $sunstone_tmpdir                = $one::params::sunstone_tmpdir,
            $oneuid                         = $one::params::oneuid,
            $onegid                         = $one::params::onegid,
            $monitoring_interval            = $one::params::monitoring_interval,
            $monitoring_threads             = $one::params::monitoring_threads,
            $information_collector_interval = $one::params::information_collector_interval,
            $http_proxy                     = $one::params::http_proxy,
            $hook_scripts_path              = $one::params::hook_scripts_path,
            $hook_scripts_pkgs              = $one::params::hook_scripts_pkgs,
            $hook_scripts                   = $one::params::hook_scripts,
            $oned_onegate_ip                = $one::params::oned_onegate_ip,
            $kickstart_network              = $one::params::kickstart_network,
            $kickstart_partition            = $one::params::kickstart_partition,
            $kickstart_rootpw               = $one::params::kickstart_rootpw,
            $kickstart_data                 = $one::params::kickstart_data,
            $kickstart_tmpl                 = $one::params::kickstart_tmpl,
            $preseed_data                   = $one::params::preseed_data,
            $preseed_debian_mirror_url      = $one::params::preseed_debian_mirror_url,
            $preseed_ohd_deb_repo           = $one::params::preseed_ohd_deb_repo,
            $preseed_tmpl                   = $one::params::preseed_tmpl,
            $backup_script_path             = $one::params::backup_script_path,
            $backup_dir                     = $one::params::backup_dir,
            $backup_opts                    = $one::params::backup_opts,
            $backup_db                      = $one::params::backup_db,
            $backup_db_user                 = $one::params::backup_db_user,
            $backup_db_password             = $one::params::backup_db_password,
            $backup_db_host                 = $one::params::backup_db_host,
            $backup_intervall               = $one::params::backup_intervall,
            $backup_keep                    = $one::params::backup_keep,
            $ssh_priv_key                   = $one::params::ssh_priv_key,
            $vm_hook_scripts                = $one::params::vm_hook_scripts,
            $host_hook_scripts              = $one::params::host_hook_scripts,
            $node_packages                  = $one::params::node_packages,
            $oned_packages                  = $one::params::oned_packages,
            $dbus_srv                       = $one::params::dbus_srv,
            $dbus_pkg                       = $one::params::dbus_pkg,
            $oned_sunstone_packages         = $one::params::oned_sunstone_packages,
            $oned_sunstone_ldap_pkg         = $one::params::oned_sunstone_ldap_pkg,
            $oned_oneflow_packages          = $one::params::oned_oneflow_packages,
            $oned_onegate_packages          = $one::params::oned_onegate_packages,
            $libvirtd_srv                   = $one::params::libvirtd_srv,
            $libvirtd_cfg                   = $one::params::libvirtd_cfg,
            $libvirtd_source                = $one::params::libvirtd_source,
            $rubygems                       = $one::params::rubygems,
            ) inherits one::params {
  include one::install
  include one::config
  include one::service

  Class['one::install']->
  Class['one::config']->
  Class['one::service']

  if ($oned) {
    if ( member(['kvm','xen3','xen4','vmware','ec2', 'qemu'], $vtype) ) {
      if ( member(['802.1Q','ebtables','firewall','ovswitch'], $ntype) ) {
        include one::oned
      } else {
        fail("Network Type: ${ntype} is not supported.")
      }
    } else {
      fail("Virtualization type: ${vtype} is not supported")
    }
  }
  if ($node) {
    include one::compute_node
  }
  if ($sunstone) {
    include one::oned::sunstone
  }
  if($oneflow) {
    class {'one::oned::oneflow': }
  }
  if($onegate) {
    class {'one::oned::onegate': }
  }
}
