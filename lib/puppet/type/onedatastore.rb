Puppet::Type.newtype(:onedatastore) do
  @doc = "Type for managing datastores in OpenNebula using the onedatastore" +
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
    desc "Name of datastore."
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

  newproperty(:preset) do
      desc "Use a preset. Valid values: filesystem, vmfs, iscsi, lvm, ceph"
  end

  newproperty(:cluster) do
      desc "Add datastore to a cluster"
  end

  newproperty(:type) do
      desc "Choose type of datastore. Valid values: images, system, files"
  end

  newproperty(:dm) do
      desc "Choose a datastore manager: filesystem, vmware, iscsi, lvm, vmfs, ceph"
  end

  newproperty(:tm) do
      desc "Choose a transport manager: shared, ssh, qcow2, iscsi, lvm, vmfs, ceph, dummy"
  end

  newproperty(:disktype) do
      desc "Choose a disk type: file, block, rdb"
  end

  newproperty(:safedirs, :array_matching => :all) do
      desc "Array of safe directories"
  end

  newproperty(:restricteddirs, :array_matching => :all) do
      desc "Array of restricted directory names"
  end

end
