Puppet::Type.newtype(:onecluster) do
  @doc = "Type for managing clusters in OpenNebula using the onecluster" +
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

  newparam(:name, :namevar => true) do
    desc "Name of cluster."
    validate do |value|
        fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newparam(:user) do
      desc "OneAdmin user name"
  end

  newparam(:password) do
      desc "OneAdmin password"
  end

  newproperty(:hosts, :array_matching => :all) do
      desc "Array with names of nodes to add to a cluster"
  end

  newproperty(:vnets, :array_matching => :all) do
      desc "Virtual Networks to add to the cluster - optional"
  end

  newproperty(:datastores, :array_matching => :all) do
      desc "Datastores to add to the cluster - optional"
  end

end
