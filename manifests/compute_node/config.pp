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
  $networkconfig     = $one::kickstart_network,
  $partitions        = $one::kickstart_partition,
  $rootpw            = $one::kickstart_rootpw,
  $data              = $one::kickstart_data,
  $kickstart_tmpl    = $one::kickstart_tmpl,
  $preseed_data      = $one::preseed_data,
  $ohd_deb_repo      = $one::preseed_ohd_deb_repo,
  $debian_mirror_url = $one::preseed_debian_mirror_url,
  $preseed_tmpl      = $one::preseed_tmpl,
  $libvirtd_cfg      = $one::libvirtd_cfg,
  $libvirtd_source   = $one::libvirtd_source,
  $libvirtd_srv      = $one::libvirtd_srv
){

  validate_string ($debian_mirror_url)
  validate_hash   ($preseed_data)

  file { '/etc/libvirt/libvirtd.conf':
    ensure => file,
    source => 'puppet:///modules/one/libvirtd.conf',
    notify => Service[$libvirtd_srv],
  } ->

  file { $libvirtd_cfg:
    ensure => file,
    source => $libvirtd_source,
    notify => Service[$libvirtd_srv],
  } ->

  file { '/etc/udev/rules.d/80-kvm.rules':
    ensure => file,
    source => 'puppet:///modules/one/udev-kvm-rules',
  } ->

  file { '/etc/sudoers.d/10_oneadmin':
    ensure => file,
    source => 'puppet:///modules/one/oneadmin_sudoers',
  } ->

  file { '/etc/sudoers.d/20_imaginator':
    ensure => file,
    source => 'puppet:///modules/one/sudoers_imaginator',
  } ->

  file { 'polkit-opennebula':
    ensure => file,
    path   => $::osfamily ? {
      'RedHat' => '/etc/polkit-1/localauthority/50-local.d/50-org.libvirt.unix.manage-opennebula.pkla',
      'Debian' => '/var/lib/polkit-1/localauthority/50-local.d/50-org.libvirt.unix.manage-opennebula.pkla',
    },
    source => 'puppet:///modules/one/50-org.libvirt.unix.manage-opennebula.pkla',
  } ->

  file { '/etc/libvirt/qemu.conf':
    ensure => file,
    source => 'puppet:///modules/one/qemu.conf'
  } ->

  file { '/var/lib/one/.virtinst':
    ensure  => directory,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0755',
  } ->

  file { '/var/lib/one/.libvirt':
    ensure  => directory,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0755',
  } ->

  file { '/var/lib/libvirt/boot':
    ensure => directory,
    owner  => 'oneadmin',
    group  => 'oneadmin',
    mode   => '0771',
  } ->

  file { ['/var/lib/one/etc/kickstart.d',
    '/var/lib/one/etc/preseed.d']:
    ensure  => directory,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    purge   => true,
    recurse => true,
    force   => true,
    mode    => '0755',
  } ->

  file { '/var/lib/one/bin/imaginator':
    ensure  => file,
    owner   => 'oneadmin',
    group   => 'oneadmin',
    mode    => '0700',
    source  => 'puppet:///modules/one/imaginator',
  }

  if ($::osfamily == 'Debian') or ($::osfamily == 'RedHat' and versioncmp($::operatingsystemmajrelease, '7') < 0) {
    file { '/sbin/brctl':
      ensure => link,
      target => '/usr/sbin/brctl',
    }
  }

  if $data {
    $data_keys = keys ($data)
    one::compute_node::add_kickstart { $data_keys:
      data => $data,
    }
  }

  if $preseed_data {
    $preseed_keys = keys ($preseed_data)
    one::compute_node::add_preseed { $preseed_keys:
      data => $preseed_data,
    }
  }
}
