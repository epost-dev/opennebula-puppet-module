# opennebula-puppet-module

[Requirements]: #requirements
[Running tests]: #running-tests
[Using the Module]: #using-the-module
[Usage of opennebula puppet resource types]: #usage-of-opennebula-puppet-resource-types

## Table of Contents

1. [Requirements][Requirements]
2. [Running tests][Running tests]
3. [Using the Module][Using the Module]
4. [Usage of opennebula puppet resource types][Usage of opennebula puppet resource types]

The one (short for OpenNebula) module allows to install and manage your OpenNebula cloud.

[![Build Status](https://travis-ci.org/epost-dev/opennebula-puppet-module.png)](https://travis-ci.org/epost-dev/opennebula-puppet-module)

## Requirements

### Supported Platforms

#### Centos 6

We support Puppet 3.1.1 on CentOS 6.7 with OpenNebula 4.12.1. 
You need to add the EPEL repository because the module needs some packages from there.

### Other Puppet Modules
One needs the following other modules:

- [puppetlabs/stdlib  > 2.2.0](https://github.com/puppetlabs/puppetlabs-stdlib)
- [puppetlabs/apt     < 2.0.0](https://github.com/puppetlabs/puppetlabs-apt)
- [puppetlabs/inifile > 1.4.0](https://github.com/puppetlabs/puppetlabs-inifile)

How to install:

    puppet module install puppetlabs-stdlib
    puppet module install puppetlabs-apt
    puppet module install puppetlabs-inifile

## Running tests

To run the rspec-puppet tests for this module install the needed gems with [bundler](http://bundler.io):

     bundle install --path=vendor

And run the tests and puppet-lint:

     bundle exec rake

### Acceptance Tests

Please note: Acceptance tests require vagrant & virtualbox to be installed.

To run acceptance tests on the default centos 6 vm:

     bundle exec rake beaker

for testing on debian wheezy simply run:

     RS_SET=debian-7-x64 bundle exec rake beaker

### Vagrant

To deploy a Opennebula instance locally run:

     vagrant up <boxname>

where "boxname" can be debian or centos

### Docker

To deploy a Opennebula instance locally in a docker container run these commandos:

First build an image with puppet and the sources in it (Depending on centos:6):

    cd docker
    docker build --rm -t epost-dev/one .
    cd ..

Run puppet in the container, choose one:

Only build a container which acts as a opennebula head, gui, but not the kvm things:

    docker run --rm -v $(pwd):/etc/puppet/modules/one epost-dev/one puppet apply /etc/puppet/modules/one/spec/docker-int/one-head.pp

Only build a container which acts like a opennebula node:

    # here is a common error i wasn't able to fix. centos 6 in docker has some issues with ksm
    docker run --rm -v $(pwd):/etc/puppet/modules/one epost-dev/one puppet apply /etc/puppet/modules/one/spec/docker-int/one-node.pp

Build a container which acts as head and node

    docker run --rm -v $(pwd):/etc/puppet/modules/one epost-dev/one puppet apply /etc/puppet/modules/one/spec/docker-int/one-head-node.pp

Build a container which has an apache for the openenbula sunstone configured:

    docker run --rm -v $(pwd):/etc/puppet/modules/one epost-dev/one puppet apply /etc/puppet/modules/one/spec/docker-int/one-head-httpd.pp

This Docker command will add the current directory as ```ect/puppet/modules/one```. So one can test each new change without committing or rebuilding the image.

The "spec" files can be found in the spec/docker-int directory of this project. One will build a one head,
one will build a node and one a head which also can be a node. 

## Using the Module

Example usage for opennebula puppet module

1. Running as OpenNebula Master with Apache and mod_passenger and Sunstone using kvm and 802.1q VLAN networking:

        class { one:
            oned               => true,
            sunstone           => true,
            sunstone_passenger => true,
        }

Attn: needs separate apache config for sunstone.

2. running opennebula node

        class { one: }


## Usage of opennebula puppet resource types

Create a ONE Vnet

    onevnet { '<name>':
        ensure          => present | absent,
        # name of the bridge to use
        bridge          => 'basebr0',
        #  name of the physical interface on which the bridge wiull run
        phydev          => 'br0',
        dnsservers      => ['8.8.8.8', '4.4.4.4'],
        gateway         => '10.0.2.1',
        # add vlanid 
        vlanid          => '1550',
        netmask         => '255.255.0.0',
        network_address => '10.0.2.0',
    }


Create onevnet addressrange

    onevnet_addressrange { '<name>':
        ensure        => present | absent,
        onevnet_name  => '<name>',            # this has to be an existing onevnet - will be autorequired if declared
        ar_id         => '<INT>',             # read only value
        protocol      => ip4 | ip6 | ip4_6 | ether,
        size          => '10',
        mac           => '02:00:0a:00:00:96', # optional
        # attributes for ip4 and ip4_6:
        ip            => '10.0.2.20'
        # attributes for ip6:
        globalprefix  => '2001:a::',          # optional
        ulaprefix     => 'fd01:a:b::',        # optional
    }

Attention: onevnet_addressrange uses the title to uniqly identify addressranges among all Virtual Networks.
The title will be set as common attribute with the name PUPPET_NAME.
This means: addressranges which are not set by Puppet will not be visible using puppet resource onevnet_addressrange command.


Create a ONE Datastore

    onedatastore { '<name>':
        ensure      => present | absent,
        type        => 'IMAGE_DS' | 'SYSTEM_DS' | 'FILE_DS',
        ds_mad      => 'fs' | 'vmware' | 'iscsi' | 'lvm' | 'vmfs' | 'ceph',
        tm_mad      => 'shared' | 'ssh' | 'qcow2' | 'iscsi' | 'lvm' | 'vmfs' | 'ceph' | 'dummy',
        driver      => 'raw | qcow2',
        ceph_host   => 'cephhost', # (optional: ceph only)
        ceph_user   => 'cephuser', # (optional: ceph only)
        ceph_secret => 'ceph-secret-here', # (optional: ceph only)
        pool_name   => 'cephpoolname', # (optional: ceph only)
        bridge_list => 'host1 host2 host3', # (optional: ceph only)
        disk_type   => 'file' | 'block' | 'rdb',
        base_path   => '/some/lib/path/datastore', #Optional
        cluster     => 'somename', # Optional
        cluster_id  => '1234', # Optional
    }


Create a ONE Host

    onehost { '<name>':
        ensure  => present | absent,
        im_mad  => 'kvm' | 'xen' | 'vmware' | 'ec2' | 'ganglia' | 'dummy' | 'custom',
        vm_mad  => 'kvm' | 'xen' | 'vmware' | 'ec2' | 'dummy' | 'custom' | 'qemu',
        vn_mad  => 'dummy' | 'firewall' | 'vlan' | 'ebtables' | 'ovswitch' | 'vmware' | 'custom',
    }


Create a ONE Cluster

    onecluster { '<name>':
        ensure     => present | absent,
        hosts      => [ 'host1', 'host2',...],
        vnets      => [ 'vnet1', 'vnet2', ...],
        datastores => [ 'ds1', 'ds2', ...],
    }


Create a ONE Image

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


Create a ONE Template

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


Create a ONE VM

    onevm { '<name>':
        ensure   => present | absent,
        template => 'template_name',
    }


Create a ONE Security Groups (ONe <= 4.12):

    onesecgroup {'securitygroup1':
       description => 'Optional description',
       rules       => [ { protocol      => 'TCP|UDP|ICMP|IPSEC|ALL',
                          rule_type     => 'INBOUND|OUTBOUND',
                          ip            => '192.168.0.0',
                          size          => '255',
                          range         => '22,53,80:90,110,1024:65535',
                          icmp_type     => 'optional, only applies for icmp',
                        },
                        { protocol  => 'ALL',
                          rule_type => 'OUTBOUND',
                        },
                        ...
                      ]
    }



##Support

For questions or bugs [create an issue on Github](https://github.com/epost-dev/opennebula-puppet-module/issues/new).

##License

Copyright © 2013 - 2015 [Deutsche Post E-Post Development GmbH](http://epost.de)

Distributed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
