Puppet::Type.newtype(:onehost) do
  @doc = <<-EOS
Type for managing hypervisor hosts in OpenNebula using the onehost wrapper
command.
EOS

  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc "Name of host."
    validate do |value|
        fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:im_mad) do
    desc "Information Driver"
  end

  newproperty(:vm_mad) do
    desc "Virtualization Driver"
  end

  newproperty(:tm_mad) do
    desc "Transfer Driver"
  end

  newproperty(:net_mad) do
      desc "Network Driver"
  end

  newproperty(:cluster) do
      desc "Cluster to add a host to"
  end
end
