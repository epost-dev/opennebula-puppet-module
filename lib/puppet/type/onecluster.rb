Puppet::Type.newtype(:onecluster) do
  @doc = "Type for managing clusters in OpenNebula using the onecluster" +
         "wrapper command."

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of cluster."
    validate do |value|
      fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:hosts, :array_matching => :all) do
    desc "Array with names of nodes to add to a cluster"
    defaultto []
  end

  newproperty(:vnets, :array_matching => :all) do
    desc "Virtual Networks to add to the cluster - optional"
    defaultto []
  end

  newproperty(:datastores, :array_matching => :all) do
    desc "Datastores to add to the cluster - optional"
    defaultto []
  end

end
