# == Class one::compute_node::config
#
# Installation and Configuration of OpenNebula
# http://opennebula.org/
# This class configures a host to serve as OpenNebula node.
#  Compute node.
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
class one::compute_node::config (
  $ssh_priv_key = $one::params::ssh_priv_key,
  $ssh_pub_key = $one::params::ssh_pub_key,
){
  file { '/etc/libvirt/libvirtd.conf':
    source => 'puppet:///modules/one/libvirtd.conf',
    owner  => 'root',
    notify => Service[$one::params::libvirtd_srv],
  }
  case $::osfamily {
      'RedHat': {
        file { '/etc/sysconfig/libvirtd':
            source => 'puppet:///modules/one/libvirtd.sysconfig',
            owner  => 'root',
            notify => Service[$one::params::libvirtd_srv],
        }
      }
      'Debian': {
          file { '/etc/default/libvirt-bin':
              source => 'puppet:///modules/one/libvirt-bin.debian',
              owner  => 'root',
              notify => Service[$one::params::libvirtd_srv],
          }
      }
      default: {
          notice('We do not know how to configure libvirtd.')
      }
  }
  file { '/etc/udev/rules.d/80-kvm.rules':
    source => 'puppet:///modules/one/udev-kvm-rules',
    owner  => 'root',
  }
  file { '/var/lib/one/.ssh':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0700',
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

  file { '/sbin/brctl':
    ensure => link,
    target => '/usr/sbin/brctl',
  }
  # sudoers for other os? default on RedHat
  file { '/etc/sudoers.d/10_oneadmin':
    ensure => file,
    source => 'puppet:///modules/one/oneadmin_sudoers',
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
  }

  if($::osfamiliy == 'RedHat') {
    file { '/etc/polkit-1/localauthority/50-local.d/50-org.libvirt.unix.manage-opennebula.pkla':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/one/50-org.libvirt.unix.manage-opennebula.pkla',
    }
  }
  file {'/etc/libvirt/qemu.conf':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/one/qemu.conf'
  }
}
