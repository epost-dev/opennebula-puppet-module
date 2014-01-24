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
  file { $one::params::libvirtd_cfg:
    ensure => 'file',
    source => $one::params::libvirtd_source,
    owner  => 'root',
    notify => Service[$one::params::libvirtd_srv],
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
 
  file {'/etc/sudoers.d/20_imaginator':
    content => 'puppet:///modules/one/sudoers_imaginator',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { '/sbin/brctl':
    ensure => link,
    target => '/usr/sbin/brctl',
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

  # Imaginator
  file { '/var/lib/one/.virtinst':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0700',
  }

  file { '/var/lib/one/.libvirt':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0700',
  }

  file { '/var/lib/one/bin':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0700',
  }

  file { '/var/lib/one/bin/imaginator':
  ensure => 'file',
  owner  => 'oneadmin',
  group  => 'oneadmin',
  mode   => '0700',
  source => 'puppet:///modules/one/imaginator'
  }

}
