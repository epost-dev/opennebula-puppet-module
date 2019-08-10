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
  @doc = 'Type for managing datastores in OpenNebula using the onedatastore wrapper command.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Name of datastore.'
    validate do |value|
      fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newparam(
    :self_test,
    :boolean => true
  ) do
    desc 'Param to activate self-test: defaults to false'
  end

  newproperty(:type) do
    desc 'Choose type of datastore. Valid values: images, system, files'
    defaultto :IMAGE_DS
    newvalues(:IMAGE_DS, :SYSTEM_DS, :FILE_DS, :image_ds, :system_ds, :file_ds)
    munge do |value|
      value.to_s.upcase.to_sym
    end
  end

  newproperty(:cluster) do
    desc 'Add datastore to a cluster'
  end

  newproperty(:cluster_id) do
    desc 'Add datastore to a cluster_id'
  end

  newproperty(:ds_mad) do
    desc 'Choose a datastore manager: filesystem, vmware, iscsi, lvm, vmfs, ceph'
  end

  newproperty(:tm_mad) do
    desc 'Choose a transport manager: shared, ssh, qcow2, iscsi, lvm, vmfs, ceph, dummy'
  end

  newproperty(:disk_type) do
    desc 'Choose a disk type: file, block, rdb'
  end

  newproperty(:driver) do
    desc 'Choose a driver: raw, qcow2'
  end

  newproperty(:base_path) do
    desc 'Choose a base path'
  end

  newproperty(:bridge_list) do
    desc 'List of frontend hosts, space separated, for Ceph'
  end

  newproperty(:ceph_host) do
    desc 'List of Ceph monitors, space separated'
  end

  newproperty(:ceph_user) do
    desc 'The OpenNebula Ceph user name. If set it is used by RBD commands'
  end

  newproperty(:ceph_secret) do
    desc 'A generated UUID for a LibVirt secret (to hold the CephX authentication key in Libvirt on each hypervisor)'
  end

  newproperty(:pool_name) do
    desc 'The OpenNebula Ceph pool name (defaults to one)'
  end

  newproperty(:staging_dir) do
    desc 'Temporary scratch space. Must be big enough to store raw image size plus sparse version'
  end

  newproperty(:safe_dirs) do
    desc 'List of safe directories, space separated'
  end


end
