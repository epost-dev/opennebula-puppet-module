opennebula-puppet-module
========================

The one (short for OpenNebula) module allows to install and manage your OpenNebula cloud.

[![Build Status](https://travis-ci.org/epost-dev/opennebula-puppet-module.png)](https://travis-ci.org/epost-dev/opennebula-puppet-module)

Requirements
------------

### Wheezy
Tested with puppet 3.4.3 from wheezy backports.
To use the open nebula repositories for wheezy, set one::enable_opennebula_repo to true and install packages for puppet and the puppetlabs-apt module:

    apt-get install -t wheezy-backports puppet
    apt-get install -t wheezy-backports puppet-module-puppetlabs-apt


Running tests
-------------
To run the rspec-puppet tests for this module install the needed gems with [bundler](http://bundler.io):

     bundle install --path=vendor

And run the tests and puppet-lint:

     bundle exec rake

To run acceptance tests:

     bundle exec rspec spec/acceptance

Using the Module
----------------

Example usage for opennebula puppet module

1. Running as OpenNebula Master with Apache and mod_passenger and Sunstone using kvm and 802.1q VLAN networking:
```
 class { one:
    oned               => true,
    sunstone_passenger => true,
 }
```

2. running opennebula vm wirt side
```
class { one: }
```

### Usage of opennebula puppet resource types


Create a ONE Vnet
```
onevnet { '<name>':
    ensure          => present | absent,
    # name of the bridge to use
    bridge          => 'basebr0',
    #  name of the physical interface on which the bridge wiull run
    phydev          => 'br0',
    type            => 'ranged' | 'fixed',
    # for ranged networking:
    network_address => '10.0.2.0',
    network_mask    => '255.255.0.0',
    # if you want to restric network usage by opennebula:
    network_start   => '10.0.2.100',
    network_end     => '10.0.2.240',
    dns_servers     => ['8.8.8.8', '4.4.4.4'],
    gateway         => '10.0.2.1',
    # select your network type
    model           => 'vlan' | 'ebtables' | 'ovswitch' | 'vmware' | 'dummy',
    # add vlanid 
    vlanid          => '1550',
}
```

Create a ONE Datastore
```
onedatastore { '<name>':
    ensure   => present | absent,
    type     => 'images' | 'system' | 'files',
    dm       => 'filesystem' | 'vmware' | 'iscsi' | 'lvm' | 'vmfs' | 'ceph',
    tm       => 'shared' | 'ssh' | 'qcow2' | 'iscsi' | 'lvm' | 'vmfs' | 'ceph' | 'dummy',
    disktype => 'file' | 'block' | 'rdb',
}
```

Create a ONE Host
```
onehost { '<name>':
    ensure  => present | absent,
    im_mad  => 'kvm' | 'xen' | 'vmware' | 'ec2' | 'ganglia' | 'dummy' | 'custom',
    vm_mad  => 'kvm' | 'xen' | 'vmware' | 'ec2' | 'dummy' | 'custom',
    vn_mad  => 'dummy' | 'firewall' | 'vlan' | 'ebtables' | 'ovswitch' | 'vmware' | 'custom',
}
```

Create a ONE Cluster
```
onecluster { '<name>':
    ensure     => present | absent,
    hosts      => [ 'host1', 'host2',...],
    vnets      => [ 'vnet1', 'vnet2', ...],
    datastores => [ 'ds1', 'ds2', ...],
}
```

Create a ONE Image
```
oneimage { '<name>':
    ensure      => present | absent,
    datastore   => 'default',
    description => 'Image description',
    type        => 'os' | 'cdrom' | 'datablock' | 'kernel' | 'ramdisk' | 'context',
    persistent  => 'yes' | 'no',
    dev_prefix  => 'hd' | 'sd' | 'xvd' | 'vd',
    target      => 'hda' | 'hdb' | 'sda' | 'sdb',
    path        => '/tmp/image_file',
    driver      => 'raw' | 'qcow2' | 'tap:aio' | 'file:',
    # non file based images
    source      => '',
    size        => '11200' # 11.2 GB
    fstype      => 'ext3',
}
```

Create a ONE Template
```
onetemplate { '<name>':
    ensure                    => present | absent,
    memory                    => '1024',
    cpu                       => '0.2',
    vcpu                      => '4',
    os_kernel                 => '/boot/vmkernel',
    os_initrd                 => '/boot/vminitrd',
    os_arch                   => 'x86_64',
    os_root                   => 'hda1',
    os_kernel_cmd             => 'quiet',
    os_bootloader             => '/sbin/lilo',
    os_boot                   => 'hd' | 'fd' | 'cdrom' | 'network',
    acpi                      => true | false,
    pae                       => true | false,
    pci_bridge                => '4',
    disks                     => [ 'disk1', 'disk2', ...],
    nics                      => [ 'nic1', 'vnet2', .. ],
    nic_model                 => 'virtio',
    graphics_type             => 'vnc' | 'sdl',
    graphics_listen           => '0.0.0.0',
    graphics_port             => '',
    graphics_password         => 'myvncpass',
    graphics_keymap           => 'de',
    context                   => { 'VAR1'  => 'value1', 'var2' => 'value2', ...},
    context_ssh_pubkey        => '$USER[SSH_PUBLIC_KEY]',
    context_network           => 'yes' | 'no',
    context_onegate           => 'yes' | 'no',
    context_files             => [ 'init.sh', 'mycontextaddon.sh'],
    context_variable          => # unused,
    context_placemant_host    => # unused,
    context_placemet_cluster  => # unused,
    context_policy            => # unused,
}
```

Create a ONE VM
```
onevm { '<name>':
    ensure   => present | absent,
    template => 'template_name',
}
```

Support
-------

For questions or bugs [create an issue on Github](https://github.com/epost-dev/opennebula-puppet-module/issues/new).

License
-------

Copyright © 2013 [Deutsche Post E-Post Development GmbH](http://epost.de)

Distributed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
