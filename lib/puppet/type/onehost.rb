# OpenNebula Puppet type for onehost
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
Puppet::Type.newtype(:onehost) do
  @doc = <<-EOS
Type for managing hypervisor hosts in OpenNebula using the onehost wrapper
command.
EOS

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of host."
    validate do |value|
      fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newparam(:self_test, :boolean => true) do
    desc "Control Flag to enable strict checking of applied changes by updating the property_hash
    after waiting on the result of an OpenNebula transaction"
  end

  newproperty(:im_mad) do
    desc "Information Driver"
    defaultto :dummy
    newvalues(:kvm, :kvm_pull, :xen, :vmware, :ec2, :ganglia, :dummy)
  end

  newproperty(:vm_mad) do
    desc "Virtualization Driver"
    defaultto :dummy
    newvalues(:kvm, :xen, :vmware, :ec2, :dummy, :qemu)
  end

  newproperty(:vn_mad) do
    desc "Network Driver"
    defaultto :dummy
    newvalues(:'802.1Q', :dummy, :ebtables, :fw, :ovswitch, :vmware)
  end

end
