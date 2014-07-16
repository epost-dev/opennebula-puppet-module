Puppet::Type.newtype(:onevnet) do
  @doc = "Type for managing networks in OpenNebula using the onevnet" +
         "wrapper command."

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
    desc "Name of network."

    isnamevar
  end

  newparam(:public) do
    desc "Public scope of the image. If true, the Virtual Network can be "+
      "used by any user. If false, the Virtual Network can only be used "+
      "by his owner. If omitted, the default value is false."

    defaultto false
  end

  newparam(:type) do
    desc "Type of network: fixed or ranged"
  end

  newparam(:bridge) do
    desc "Name of the physical bridge on each host to use."
  end

  newparam(:leases) do
    desc "Leases to assign in fixed networking."
  end

  newparam(:network_size) do
    desc "Size of network (A,B or C) For ranged networking"
  end

  newparam(:network_address) do
    desc "Base network for ranged networking."
  end

  newparam(:context) do
    desc "A hash of context information to also store in the template."
  end
end
