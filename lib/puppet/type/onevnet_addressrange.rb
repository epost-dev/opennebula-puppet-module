# OpenNebula Puppet type for onevnet addressrange
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
Puppet::Type.newtype(:onevnet_addressrange) do
  @doc = "Type for managing addressranges in networks in OpenNebula using the onevnet" +
         "wrapper command."

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name (ID) of addressrange."
    validate do |value|
      fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newparam(:onevnet) do
    desc "Name of the onevnet network where the addressrange will be added/managed"
  end

  newproperty(:protocol) do
    desc "Type of the addressrange. Valid values: IP4, IP6, IP4_6"
    newvalues(:ip4, :ip6, :ip4_6)
  end

  newproperty(:ip_start) do
    desc "Base ip address for IPv4 networks."
    validate do |value|
        unless resource[:ensure] == :present and resource[:protocol] == :ip4
            fail("Network address is required when using IPv4 protocol")
        end
        if value == :undef and resource[:ensure] == :present and resource[:protocol] == :ip4
            fail("network_address is required when using ipv4")
        end
    end
  end

  newproperty(:ip_size) do
    desc "Number of addresses"
    validate do |value|
        unless resource[:ensure] == :present and ( resource[:protocol] == :ip4 or resource[:protocol] == :ip4_6 )
            fail("ip_size is required when using IPv4 protocol")
        end
        if value == :undef and resource[:ensure] == :present and ( resource[:protocol] == :ip4 or resource[:protocol] == :ip4_6 )
            fail("network_mask is required when using ipv4")
        end
    end
  end

  newproperty(:mac) do
    desc "First MAC (optional)"
  end

  newproperty(:globalprefix) do
    desc "Global prefix for IPv6 network"
    validate do |value|
        unless resource[:ensure] == :present and ( resource[:protocol] == :ip6 or resource[:protocol] == :ip4_6 )
            fail("Global prefix is required when using IPv6 protocol")
        end
    end
  end

  newproperty(:ulaprefix) do
    desc "ULA prefix for IPv6 network"
  end

end
