Puppet::Type.newtype(:onedatastore) do
  @doc = "Type for managing datastores in OpenNebula using the onedatastore" +
         "wrapper command."

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of datastore."
    validate do |value|
        fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

#  newproperty(:preset) do
#      desc "Use a preset. Valid values: filesystem, vmfs, iscsi, lvm, ceph"
#  end

#  newproperty(:cluster) do
#      desc "Add datastore to a cluster"
#  end

  newproperty(:type) do
    desc "Choose type of datastore. Valid values: images, system, files"
    defaultto :IMAGE_DS
    newvalues(:IMAGE_DS, :SYSTEM_DS, :FILE_DS, :image_ds, :system_ds, :file_ds)
    munge do |value|
      value.to_s.upcase.to_sym
    end
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

  newproperty(:safe_dirs, :array_matching => :all) do
    desc "Array of safe directories"
  end

#  newproperty(:restricteddirs, :array_matching => :all) do
#      desc "Array of restricted directory names"
#  end

end
