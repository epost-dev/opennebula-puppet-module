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

  newproperty(:im_mad) do
    desc "Information Driver"
    defaultto :dummy
    newvalues(:kvm, :xen, :vmware, :ec2, :ganglia, :dummy)
  end

  newproperty(:vm_mad) do
    desc "Virtualization Driver"
    defaultto :dummy
    newvalues(:kvm, :xen, :vmware, :ec2, :dummy)
  end

  newproperty(:vn_mad) do
    desc "Network Driver"
    defaultto :dummy
    newvalues(:'802.1Q', :dummy, :ebtables, :fw, :ovswitch, :vmware)
  end

end
