# opennebula-puppet-module

The one (short for OpenNebula) module allows to install and manage your OpenNebula cloud.

[![Build Status](https://travis-ci.org/epost-dev/opennebula-puppet-module.png)](https://travis-ci.org/epost-dev/opennebula-puppet-module)

## Requirements

### Debian Wheezy

Tested with puppet 3.7.4 from wheezy backports.
To use the open nebula repositories for wheezy, set one::enable_opennebula_repo to true and install packages for puppet and the puppetlabs-apt module:

    apt-get install -t wheezy-backports puppet
    apt-get install -t wheezy-backports puppet-module-puppetlabs-apt

### Centos

Tested on Centos 6 with Puppet 3.7.4 from Puppetlabs Repositories.
You need to add the EPEL Repos.

## Running tests

To run the rspec-puppet tests for this module install the needed gems with [bundler](http://bundler.io):

     bundle install --path=vendor

And run the tests and puppet-lint:

     bundle exec rake

To run acceptance tests on the default centos 6 vm:

     bundle exec rake beaker

for testing on debian wheezy simply run:

     RS_SET=debian-7-x64 bundle exec rake beaker

## Vagrant

To deploy a Opennebula instance locally run:

     vagrant up <boxname>

where "boxname" can be debian or centos

## Using the Module

Example usage for opennebula puppet module

1. Running as OpenNebula Master with Apache and mod_passenger and Sunstone using kvm and 802.1q VLAN networking:
```
 class { one:
    oned               => true,
    sunstone           => true,
    sunstone_passenger => true,
 }
```
Attn: needs separate apache config for sunstone.

2. running opennebula node
```
class { one: }
```

## Usage of opennebula puppet resource types

Create a ONE Vnet
```
onevnet { '<name>':
    ensure          => present | absent,
    # name of the bridge to use
    bridge          => 'basebr0',
    #  name of the physical interface on which the bridge wiull run
    phydev          => 'br0',
    dns_servers     => ['8.8.8.8', '4.4.4.4'],
    gateway         => '10.0.2.1',
    network_address => '10.0.2.0',
    network_mask    => '255.255.255.0',
    # add vlanid 
    vlanid          => '1550',
    # configure address range (only one range is possible at the moment)
    addressrange    => { 'ip' => '10.0.2.10', 'size' => '10', 'type' => 'IP4 | ETHER | IP4_6 | IP6', 'mac' => '00:00:00:00:00:00', 'global_prefix' => '::1' }, 
    
}
```

Create a ONE Datastore
```
onedatastore { '<name>':
    ensure   => present | absent,
    type     => 'IMAGE_DS' | 'SYSTEM_DS' | 'FILE_DS',
    dm       => 'fs' | 'vmware' | 'iscsi' | 'lvm' | 'vmfs' | 'ceph',
    tm       => 'shared' | 'ssh' | 'qcow2' | 'iscsi' | 'lvm' | 'vmfs' | 'ceph' | 'dummy',
    disktype => 'file' | 'block' | 'rdb',
    basepath => '/var/lib/one/datastore',
}
```

Create a ONE Host
```
onehost { '<name>':
    ensure  => present | absent,
    im_mad  => 'kvm' | 'xen' | 'vmware' | 'ec2' | 'ganglia' | 'dummy' | 'custom',
    vm_mad  => 'kvm' | 'xen' | 'vmware' | 'ec2' | 'dummy' | 'custom' | 'qemu',
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
    disk_type   => 'os' | 'cdrom' | 'datablock' | 'kernel' | 'ramdisk' | 'context',
    persistent  => 'true' | 'false',
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
    features                  => { 'acpi' => 'yes|no', 'pae' => 'true|false' },
    os                        => { 'kernel' => '/boot/vmkernel', 'initrd' => '/boot/vminitrd', 'arch' => 'x86_64', 'root' => 'hda1', 'bootloader' => '/sbin/lilo', 'boot' => 'hd|fd|cdrom|network' }
    pci_bridge                => '4',
    disks                     => [ 'disk1', 'disk2', ...],
    nics                      => [ 'nic1', 'vnet2', .. ],
    nic_model                 => 'virtio',
    graphics                  => { 'type' => 'vnc|sdl', 'listen' => '0.0.0.0', 'password' => 'myvncpass', 'keymap' => 'de' },
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

##Support

For questions or bugs [create an issue on Github](https://github.com/epost-dev/opennebula-puppet-module/issues/new).

##License

Copyright © 2013 [Deutsche Post E-Post Development GmbH](http://epost.de)

Distributed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
