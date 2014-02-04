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
# - Robert Waffen
#
# === License
# Apache License Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0.html
#
class one::compute_node::config (
  $head_ssh_pub_key = $one::params::ssh_pub_key,
  $networkconfig    = $one::params::kickstart_network,
  $partitions       = $one::params::kickstart_partition,
  $rootpw           = $one::params::kickstart_rootpw,
  $yum_repo_puppet  = $one::params::kickstart_yum_repo_puppet,
  $ohd_repo_puppet  = $one::params::kickstart_ohd_repo_puppet
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

  file { '/var/lib/one/.ssh/authorized_keys':
    content => $head_ssh_pub_key,
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

  file { '/etc/sudoers.d/10_oneadmin':
    source => 'puppet:///modules/one/oneadmin_sudoers',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { '/etc/sudoers.d/20_imaginator':
    source => 'puppet:///modules/one/sudoers_imaginator',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { '/sbin/brctl':
    ensure => link,
    target => '/usr/sbin/brctl',
  }

  if ($::osfamiliy == 'RedHat') {
    file { '/etc/polkit-1/localauthority/50-local.d/50-org.libvirt.unix.manage-opennebula.pkla':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/one/50-org.libvirt.unix.manage-opennebula.pkla',
    }
  }

  file { '/etc/libvirt/qemu.conf':
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
    mode   => '0755',
  }

  file { '/var/lib/one/.libvirt':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0755',
  }

  file { '/var/lib/libvirt/boot':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0771',
  }

  file { '/var/lib/one/bin':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0755',
  }

  file { '/var/lib/one/etc':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
  }

  file { '/var/lib/one/etc/kickstart.d':
    ensure  => directory,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    require => File['/var/lib/one/etc'],
  }

  file { '/var/lib/one/etc/kickstart.d/kickstart.ks':
    ensure  => present,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    content => template('one/kickstart.erb'),
    require => File['/var/lib/one/etc/kickstart.d'],
  }

  file { '/var/lib/one/bin/imaginator':
    ensure => 'file',
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0700',
    source => 'puppet:///modules/one/imaginator'
  }
}
