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

  newproperty(:model) do
    desc "Model of network - deprecated parameter. For opennebula 5.0 use vn_mad, for earlier versions this parameter is unused"
    validate do |value|
      Puppet.deprecation_warning("Specifying model on onevnet is deprecated and unused. For opennebula 5.0 use vn_mad, for earlier versions this parameter is unused")
    end
    newvalues(:vlan, :ebtables, :ovswitch, :vmware, :dummy)
  end

  newproperty(:vn_mad) do
    desc "The network driver to implement the network. Can be any of 802.1Q, ebtables, fw, ovswtich, vxlan, vcenter, dummy. NOTE only used in Opennebula 5.0"
    newvalues(:'802.1Q', :ebtables, :fw, :ovswitch, :vxlan, :vcenter, :dummy)
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

  newproperty(:dnsservers, :array_matching => :all) do
    desc "Array of DNS servers to use"
  end

  newproperty(:netmask) do
      desc "Netmask for the network"
  end

  newproperty(:network_address) do
      desc "Network address for the network"
  end

  newproperty(:gateway) do
      desc "Gateway for network"
  end

  newproperty(:mtu) do
      desc "MTU for network"
  end

  newproperty(:context) do
    desc "A hash of context information to also store in the template."
  end

end
