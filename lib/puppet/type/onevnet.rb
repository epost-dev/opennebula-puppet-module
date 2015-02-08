# OpenNebula Puppet type for onevnet
#
# License: APLv2
#
# Authors:
# Based upon initial work from Ken Barber
# Modified by Martin Alfke
#
# Copyright
# initial provider had no copyright
# Deutsche Post E-POST Development GmbH - 2014, 2015
#
#require 'IPAddress'
Puppet::Type.newtype(:onevnet) do
  @doc = "Type for managing networks in OpenNebula using the onevnet" +
         "wrapper command."

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of network."
    validate do |value|
      fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:network_address) do
    desc "Base network address for IPv4 networks."
#    validate do |value|
#        unless resource[:ensure] == :present and resource[:protocol] == :ipv4
#            fail("Network address is required when using IPv4 protocol")
#        end
#        if value == :undef and resource[:ensure] == :present
#            fail("network_address is required when using ipv4")
#        end
#    end
  end

  newproperty(:network_mask) do
    desc "Base network mask for IPv4 networks."
#    validate do |value|
#        unless resource[:ensure] == :present and resource[:protocol] == :ipv4
#            fail("Network mask is required when using IPv4 protocol")
#        end
#        if value == :undef and resource[:ensure] == :present
#            fail("network_mask is required when using ipv4")
#        end
#    end
  end

  newproperty(:siteprefix) do
#    desc "Siteprefix for IPv6 network"
#    validate do |value|
#        unless resource[:ensure] == :present and resource[:protocol] == :ipv6
#            fail("Siteprefix is required when using IPv6 protocol")
#        end
#    end
  end

  newproperty(:globalprefix) do
    desc "Global prefix for IPv6 network"
#    validate do |value|
#        unless resource[:ensure] == :present and resource[:protocol] == :ipv6
#            fail("Global prefix is required when using IPv6 protocol")
#        end
#    end
  end

  newproperty(:dnsservers, :array_matching => :all) do
    desc "Array of DNS servers to use"
#      validate do |value|
#          unless resource[:ensure] == :present and value != :undef
#              fail("DNS servers are required")
#          end
#      end
  end

  newproperty(:gateway) do
      desc "Gateway for network"
#      validate do |value|
#          unless resource[:ensure] == :present and value != :undef
#              fail("Gateway is required")
#          end
#      end
  end

  newproperty(:macstart) do
    desc "IPv6 MAC start address for ranged IPv6 networks"
#      validate do |value|
#        if resource[:protocol] == :ipv4
#            fail("You may not use IPv6 macstart attribute on IPv4 networks")
#        else
#             unless value =~ /^([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}$/ 
#               raise ArgumentError, "macstart must be a mac address, not #{value}"
#             end
#        end
#      end
  end

  newproperty(:network_size) do
    desc "Network size for IPv6 ranged networks"
#      validate do |value|
#        unless resource[:protocol] == :ipv6
#            fail("You may not use network_site attribute on IPv4 networks. Your protocol is #{resource[:protocol]}")
#        end
#      end
  end

  newproperty(:leases, :array_matching => :all) do
    desc "Leases to assign in fixed networking. Needs IP and MAC as hash"
  end

  newproperty(:model) do
    desc "Network model to use. Can be any of vlan (=8021q), ebtables, ovswitch, vmware"
    newvalues(:vlan, :ebtables, :ovswitch, :vmware, :dummy)
  end

  newproperty(:vlanid) do
    desc "ID of 802.1Q VLAN ID"
  end

  newproperty(:bridge) do
    desc "Name of the physical bridge on each host to use."
  end

  newproperty(:phydev) do
    desc "Name of the physical device on which the vnet is available"
  end

  newproperty(:context) do
    desc "A hash of context information to also store in the template."
  end

end
