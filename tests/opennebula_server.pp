# example usage for opennebula puppet module
#
# 1. Running as OpenNebula Master with Apache and mod_passenger and Sunstone
#    using kvm and 802.1q VLAN networking:
class { one:
    oned               => true,
    sunstone_passenger => true,
}

# 2. running opennebula vm wirt side
class { one: }

# Usage of opennebula puppet resource types

onevnet { '<name>':
    ensure => present,
    # name of the bridge to use
    bridge => 'basebr0',
    #  name of the physical interface on which the bridge wiull run
    phydev => 'br0',
    type   => 'ranged' | 'fixed',
    # for ranged networking:
    network_address => '10.0.2.0',
    network_mask    => '255.255.0.0',
    # if you want to restric network usage by opennebula:
    network_start => '10.0.2.100',
    network_end   => '10.0.2.240',
    dns_servers   => ['8.8.8.8', '4.4.4.4'],
    gateway       => '10.0.2.1',
    # select your network type
    model         => 'vlan' | 'ebtables' | 'ovswitch' | 'vmware' | 'dummy',
    # add vlanid 
    vlanid        => '1550',
}
