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
# ==== OpenNebula general parameters
#
# $oneid <string> - default to one-cloud
#   set the id of the cloud
#
# $node true|false - default true
#  defines whether the host is node (virtualization host/worker)
#
# $im_mad - default kvm
#  set Information Manager driver for opennebula compute node
#  supported types:
#   - kvm
#   - xen
#   - vmware
#   - ec2
#   - ganglia
#   - dummy
#
# $vm_mad - default kvm
#  set virtualization type for opennebula compute node
#  supported types:
#   - kvm
#   - xen
#   - vmware
#   - ec2
#   - dummy
#   - qemu
#
# $vn_mad - default 802.1Q
#  set network type for opennebula compute node
#  supported types:
#   - 802.1Q
#   - ebtables
#   - firewall
#   - ovswitch
#   - vmware
#   - dummy
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
# $sunstone_novnc - default false
#   defines whether novnc should be started for sunstone web interface
#   fully optional and only used if $sunstone is set to true
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
#   defines to use puppetDB to discover peer nodes (hypervisors)
#
# $debug_level - default 0
#   defines the debug level under which oned and sunstone are running
#
# ==== OpenNebula configuration parameters
#
# ===== OpenNebula Database configuration
#
# $oned_db - default oned
#   name of the oned database
#
# $oned_db_user - default oned
#   name of the database user
#
# $oned_db_password - default oned
#   password of the database user
#
# $oned_db_host - default localhost
#   oned database host
# 
# ===== OpenNebula LDAP configuration
# optional needs $ldap set to true
#
# $oned_ldap_host - default ldap
#   hostname of the ldap server
#
# $oned_ldap_port - default 636
#   port of the ldap service
#
# $oned_ldap_base - default dc=example,dc=com
#   ldap base
#
# $oned_ldap_user - default cn=ldap_query,ou=user,dc=example,dc=com
#   ldap user for queries - can be empty if anonymous query is possible
#   
# $oned_ldap_pass - default default_password
#   ldap user password for queries - can be empty if anonymous query is possible
#
# $oned_ldap_group - default undef
#   restrict access to certain groups - cen be undef to allow all user access
#
# $oned_ldap_user_field - default undef
#   defaults to uid, can be set to the field, that holds the username in ldap
#
# $oned_ldap_group_field - default undef
#   default to member, can be set to the filed that holds the groupname
#
# $oned_ldap_user_group_field - default undef
#   default to dn, can be set to the user field that is in the group group_field
#
# ===== OpenNebula User configuration
#
# $oneuid - default 9869
#   set the oneadmin user id
#
# $onegid - default 9869
#   set the oneadmin group id
#
# $ssh_priv_key_param - default undef
#   add the private key to oneadmin user
#
# $ssh_pub_key - default undef
#   add public key to oneadmin user
#
# ===== OpenNebula XMLRPC configuration
#
# $xmlrpc_max_conn - default 15
#   set maximum number of connections
#
# $xmlrpc_maxconn_backlog - default 15
#   set maximum number of queued connections
#
# $xmlrpc_keepalive_timeout - default 15
#   set xmlrpc keepalive timeout in seconds
#
# $xmlrpc_keepalive_max_conn - default 30
#   set xmlrpc active connection timeout in seconds
#
# $xmlrpc_timeout - default 15
#   set xmlrpc timout in seconds
#
# ===== OpenNebula Sunstone configuration
#
# $sunstone_listen_ip - default 127.0.0.1
#   set the ip where sunstone interface should listen
#
# $enable_support - default yes
#   enable support button in sunstone
#
# $enable_marketplace - default yes
#   enable marketplace button in sunstone
#
# $sunstone_tmpdir - default /var/tmp
#   define a different tmp dir for sunstone
#
# $sunstone_logo_png - default use ONE logo
#   use custom logo on sunstone login page
#   used as the 'source' for image file resource
#   e.g. puppet:///modules/mymodule/my-custom-logo.png
#
# $sunstone_logo_small_png - default use ONE logo
#   use custom small logo in upper left corner of sunstone admin
#   used as the 'source' for image file resource
#   e.g. puppet:///modules/mymodule/my-custom-small-logo.png
#
# ===== OpenNebula host monitoring configuration
# $monitoring_interval - default 60
#   when shoudl monitoring start again in seconds
#
# $monitoring_threads - default 50
#   how many monitoring threads should be started
#
# $information_collector_interval - default 20
#   how often should monitoring data get collected
#
# ===== OpenNebula Hook Script configuration
#
# hook scripts can either be placed in puppet or in a package
#
# $hook_scripts - default undef
#   should hook script be installed
#   either undef or a hash. two keys are supported:
#       - VM - VM hook scripts
#       - HOST - HOST hook scripts
#   hiera data example:
#        # Configures the hook scripts for VM and HOST in oned.conf
#        one::head::hook_scripts:
#          VM:
#            dnsupdate:
#              state:      'CREATE'
#              command:    '/usr/share/one/hooks/dnsupdate.sh'
#              arguments:  '$TEMPLATE'
#              remote:      'no'
#            dnsupdate_custom:
#              state:        'CUSTOM'
#              custom_state: 'PENDING'
#              lcm_state:    'LCM_INIT'
#              command:    '/usr/share/one/hooks/dnsupdate.sh'
#              arguments:  '$TEMPLATE'
#              remote:      'no'
#          HOST:
#            error:
#              state:      'ERROR'
#              command:    'ft/host_error.rb'
#              arguments:  '$ID -r'
#              remote:      'no'
#
# $hook_scripts_path - default puppet:///modules/one/hookscripts
#   path where puppet will look for hook scripts
#
# $hook_scripts_pkgs - default undef
#   package which will have the hook scripts
#   hiera data example:
#        #Install additional packages which contains the hook scripts
#        one::head::hook_script_pkgs:
#            - 'hook_vms'
#            - 'hook_hosts'
#
# ===== OpenNebula OneGate configuration
#
# $oned_onegate_ip - default $::ipaddress
#   which ip should the onegate daemon listen on
#
# ==== Imaginator configuration
#
# $kickstart_network - default undef
# $kickstart_partition - default undef
# $kickstart_rootpw - default undef
# $kickstart_data - default undef
# $kickstart_tmpl - default one/kickstart.ks.erb
# $preseed_data - default {}
# $preseed_debian_mirror_url - default http://ftp.debian.org/debian
# $preseed_ohd_deb_repo - default undef
# $preseed_tmpl - default  one/preseed.cfg.erb
#
# ==== Database Backup configuration
#
# $backup_script_path - default /var/lib/one/bin/one_db_backup.sh
# $backup_dir - default /srv/backup
# $backup_opts - default -C -q -e
# $backup_db - default oned
# $backup_db_user - default onebackup
# $backup_db_password - default onebackup
# $backup_db_host - default localhost
# $backup_intervall - default */10
# $backup_keep - default -mtime +15
#
# ==== OS specific configuration
#
# set in manifests/params for each os.
#
# $node_packages
# $oned_packages 
# $dbus_srv 
# $dbus_pkg 
# $oned_sunstone_packages 
# $oned_sunstone_ldap_pkg 
# $oned_oneflow_packages 
# $oned_onegate_packages 
# $libvirtd_srv 
# $libvirtd_cfg 
# $libvirtd_source 
# $rubygems 
#
# ==== Environment specific configuration
#
# $http_proxy - default ''
#   set to proxy if you can not install gems directly
#
# $one_repo_enable - default true
#   should the official opennebula repositories be enabled?
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
  $im_mad             = 'kvm',
  $vm_mad             = 'kvm',
  $vn_mad             = '802.1Q',
  $oned               = false,
  $sunstone           = false,
  $sunstone_passenger = false,
  $sunstone_novnc     = false,
  $ldap               = false,
  $oneflow            = false,
  $onegate            = false,
  $backend            = 'sqlite',
  $ha_setup           = false,
  $puppetdb           = false,
  $debug_level        = '0',
  $oned_port                      = $one::params::oned_port,
  $oned_db                        = $one::params::oned_db,
  $oned_db_user                   = $one::params::oned_db_user,
  $oned_db_password               = $one::params::oned_db_password,
  $oned_db_host                   = $one::params::oned_db_host,
  $oned_vm_submit_on_hold         = $one::params::oned_vm_submit_on_hold,
  $oned_default_auth              = $one::params::oned_default_auth,
  $oned_ldap_host                 = $one::params::oned_ldap_host,
  $oned_ldap_port                 = $one::params::oned_ldap_port,
  $oned_ldap_base                 = $one::params::oned_ldap_base,
  $oned_ldap_user                 = $one::params::oned_ldap_user,
  $oned_ldap_pass                 = $one::params::oned_ldap_pass,
  $oned_ldap_group                = $one::params::oned_ldap_group,
  $oned_ldap_user_field           = $one::params::oned_ldap_user_field,
  $oned_ldap_group_field          = $one::params::oned_ldap_group_field,
  $oned_ldap_user_group_field     = $one::params::oned_ldap_user_group_field,
  $oned_ldap_mapping_generate     = $one::params::oned_ldap_mapping_generate,
  $oned_ldap_mapping_timeout      = $one::params::oned_ldap_mapping_timeout,
  $oned_ldap_mapping_filename     = $one::params::oned_ldap_mapping_filename,
  $oned_ldap_mappings             = $one::params::oned_ldap_mappings,
  $oned_ldap_mapping_key          = $one::params::oned_ldap_mapping_key,
  $oned_ldap_mapping_default      = $one::params::oned_ldap_mapping_default,
  $one_repo_enable                = $one::params::one_repo_enable,
  $ssh_priv_key_param             = $one::params::ssh_priv_key_param,
  $ssh_pub_key                    = $one::params::ssh_pub_key,
  $xmlrpc_maxconn                 = $one::params::xmlrpc_maxconn,
  $xmlrpc_maxconn_backlog         = $one::params::xmlrpc_maxconn_backlog,
  $xmlrpc_keepalive_timeout       = $one::params::xmlrpc_keepalive_timeout,
  $xmlrpc_keepalive_max_conn      = $one::params::xmlrpc_keepalive_max_conn,
  $xmlrpc_timeout                 = $one::params::xmlrpc_timeout,
  $sunstone_listen_ip             = $one::params::sunstone_listen_ip,
  $sunstone_logo_png              = $one::params::sunstone_logo_png,
  $sunstone_logo_small_png        = $one::params::sunstone_logo_small_png,
  $enable_support                 = $one::params::enable_support,
  $enable_marketplace             = $one::params::enable_marketplace,
  $sunstone_tmpdir                = $one::params::sunstone_tmpdir,
  $vnc_proxy_port                 = $one::params::vnc_proxy_port,
  $vnc_proxy_support_wss          = $one::params::vnc_proxy_support_wss,
  $vnc_proxy_cert                 = $one::params::vnc_proxy_cert,
  $vnc_proxy_key                  = $one::params::vnc_proxy_key,
  $vnc_proxy_ipv6                 = $one::params::vnc_proxy_ipv6,
  $oneuid                         = $one::params::oneuid,
  $onegid                         = $one::params::onegid,
  $monitoring_interval            = $one::params::monitoring_interval,
  $monitoring_threads             = $one::params::monitoring_threads,
  $information_collector_interval = $one::params::information_collector_interval,
  $http_proxy                     = $one::params::http_proxy,
  $hook_scripts_path              = $one::params::hook_scripts_path,
  $hook_scripts_pkgs              = $one::params::hook_scripts_pkgs,
  $hook_scripts                   = $one::params::hook_scripts,
  $inherit_datastore_attrs        = $one::params::inherit_datastore_attrs,
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
  $kvm_driver_emulator            = $one::params::kvm_driver_emulator,
  $kvm_driver_nic_attrs           = $one::params::kvm_driver_nic_attrs,
  $rubygems                       = $one::params::rubygems,
  $sched_interval                 = $one::params::sched_interval,
  $sched_max_vm                   = $one::params::sched_max_vm,
  $sched_max_dispatch             = $one::params::sched_max_dispatch,
  $sched_max_host                 = $one::params::sched_max_host,
  $sched_live_rescheds            = $one::params::sched_live_rescheds,
  $sched_default_policy           = $one::params::sched_default_policy,
  $sched_default_rank             = $one::params::sched_default_rank,
  $sched_default_ds_policy        = $one::params::sched_default_ds_policy,
  $sched_default_ds_rank          = $one::params::sched_default_ds_rank,
  $sched_log_system               = $one::params::sched_log_system,
  $sched_log_debug_level          = $one::params::sched_log_debug_level,
  $datastore_capacity_check       = $one::params::datastore_capacity_check,
  $default_image_type             = $one::params::default_image_type,
  $default_device_prefix          = $one::params::default_device_prefix,
  $default_cdrom_device_prefix    = $one::params::default_cdrom_device_prefix,
  $one_version                    = $one::params::one_version,
) inherits one::params {

  # check if version greater than or equal to 4.14 (used in templates)
  if ( versioncmp($one_version, '4.14') >= 0 ) {
    $version_gte_4_14 = true
  }
  else {
    $version_gte_4_14 = false
  }

  include one::prerequisites
  include one::install
  include one::config
  include one::service

  Class['one::prerequisites']->
  Class['one::install']->
  Class['one::config']->
  Class['one::service']

  if ($oned) {
    if ( member(['kvm','xen','vmware','ec2', 'ganglia','dummy'], $im_mad) ) {
      if ( member(['kvm','xen','vmware','ec2', 'qemu', 'dummy'], $vm_mad) ) {
        if ( member(['802.1Q','ebtables','firewall','ovswitch','vmware','dummy'], $vn_mad) ) {
          include one::oned
        } else {
          fail("Network Type: ${vn_mad} is not supported.")
        }
      } else {
        fail("Virtualization type: ${vm_mad} is not supported")
      }
    } else {
      fail("Information Manager type: ${im_mad} is not supported")
    }
  }
  if ($node) {
    include one::compute_node
  }
  if ($sunstone) {
    include one::oned::sunstone
  }
  if($oneflow) {
    include one::oned::oneflow
  }
  if($onegate) {
    include one::oned::onegate
  }
}
