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
class one::params {
  # generic params for nodes and oned
  $oneid = $one::oneid

  # should we enable opennebula repos?
  $one_repo_enable = hiera('one::enable_opennebula_repo', false )

  $oneuid = '9869'
  $onegid = '9869'

  # the priv key is mandatory on the head.
  if (!$one::node) {
    $ssh_priv_key = hiera('one::head::ssh_priv_key')
  }
  # The pub key should be available on both hosts.
    $ssh_pub_key  = hiera('one::head::ssh_pub_key')

  #Allows it to be overwritten by custom puppet profile
  #Should be the path to the folder which should be the source on the master
  $hook_scripts_path = hiera('one::head::hook_script_path', 'puppet:///modules/one/hookscripts')

  # Todo: Use Serviceip from HA-Setup if ha enabled.
  $oned_onegate_ip = hiera('one::oned::onegate::ip', $::ipaddress)

  # params for nodes
  case $::osfamily {
    'RedHat': {
      $node_packages = ['opennebula-node-kvm',
                        'sudo',
                        'python-virtinst'
                        ]
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
    }
    'Debian': {
      $node_packages   = ['opennebula-node',
                          'sudo',
                          'virtinst'
                          ]
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

  # mysql stuff (optional, need one::mysql set to true)
  $oned_db            = hiera('one::oned::db', 'oned')
  $oned_db_user       = hiera('one::oned::db_user', 'oned')
  $oned_db_password   = hiera('one::oned::db_password', 'oned')
  $oned_db_host       = hiera('one::oned::db_host', 'localhost')

  $ha_setup = hiera('one::ha_setup', true)
  # ha stuff (optional, needs one::ha_setup set to true)
  if ($ha_setup) {
    $oned_enable = false
    $oned_ensure = undef
  } else {
    $oned_enable = true
    $oned_ensure = 'running'
  }

  # ldap stuff (optional needs one::oned::ldap in hiera set to true)
  $oned_ldap_host = hiera('one::oned::ldap_host','ldap')
  $oned_ldap_port = hiera('one::oned::ldap_port','636')
  $oned_ldap_base = hiera('one::oned::ldap_base','dc=example,dc=com')
  # $oned_ldap_user: can be empty if anonymous query is possible
  $oned_ldap_user = hiera('one::oned::ldap_user',
                          'cn=ldap_query,ou=user,dc=example,dc=com')
  $oned_ldap_pass = hiera('one::oned::ldap_pass','default_password')
  # $oned_ldap_group: can be empty,
  #     can be set to a group to restrict access to sunstone
  $oned_ldap_group = hiera( 'one::oned::ldap_group', 'undef')
  # $oned_ldap_user_field: defaults to uid, can be set to the field,
  #     that holds the username in ldap
  $oned_ldap_user_field = hiera('one::oned::ldap_user_field','undef')
  # $oned_ldap_group_field: default to member,
  #     can be set to the filed that holds the groupname
  $oned_ldap_group_field = hiera('one::oned::ldap_group_field', 'undef')
  # $oned_ldap_user_group_field: default to dn,
  #     can be set to the user field that is in the group group_field
  $oned_ldap_user_group_field = hiera('one::oned::ldap_user_group_field','undef')

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

  $backup_script_path        = hiera ('one::oned::backup::script_path', '/var/lib/one/bin/one_db_backup.sh')
  $backup_dir                = hiera ('one::oned::backup::dir', '/srv/backup')
  $backup_opts               = hiera ('one::oned::backup::opts', '-C -q -e')
  $backup_db                 = hiera ('one::oned::backup::db', 'oned')
  $backup_db_user            = hiera ('one::oned::backup::db_user', 'onebackup')
  $backup_db_password        = hiera ('one::oned::backup::db_password', 'onebackup')
  $backup_db_host            = hiera ('one::oned::backup::db_host', 'localhost')
  $backup_intervall          = hiera ('one::oned::backup::intervall', '*/10')
  $backup_keep               = hiera ('one::oned::backup::keep', '-mtime +15')

  $puppet_hook               = hiera ('one::oned::puppet_hook', 'false')
}