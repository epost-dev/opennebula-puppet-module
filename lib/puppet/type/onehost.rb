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

  newparam(:name) do
    desc "Name of host."

    isnamevar
  end

  newparam(:im_mad) do
    desc "Information Driver"
  end

  newparam(:vm_mad) do
    desc "Virtualization Driver"
  end

  newparam(:tm_mad) do
    desc "Transfer Driver"
  end
end
