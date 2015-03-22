# OpenNebula Puppet type for onedatastore
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

  newproperty(:basepath) do
    desc "Choose a base path"
  end

  newproperty(:bridgelist) do
    desc "List of frontend hosts, space separated, for Ceph"
  end

  newproperty(:cephhost) do
    desc "List of Ceph monitors, space separated"
  end

  newproperty(:stagingdir) do
    desc "Temporary scratch space. Must be big enough to store raw image size plus sparse version"
  end

  newproperty(:safe_dirs, :array_matching => :all) do
    desc "Array of safe directories"
  end

#  newproperty(:restricteddirs, :array_matching => :all) do
#      desc "Array of restricted directory names"
#  end

end
