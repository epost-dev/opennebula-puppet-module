Puppet::Type.newtype(:oneimage) do
  @doc = "Type for managing Images, Files and Kernels in OpenNebula using the oneimage " +
         "wrapper command."

  ensurable

  newparam(:name, :namevar => true) do
    desc "Name of image."
    validate do |value|
        fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:datastore) do
    desc "Selects the datastore"
    defaultto :default
    newvalues(/^\w+$/)
  end

  newproperty(:description) do
    desc "Description of image"
  end

  newproperty(:type) do
    desc "Type of image: os, cdrom, datablock, kernel, ramdisk or context"
    defaultto :OS
    newvalues(:OS, :os, :CDROM, :cdrom, :DATABLOCK, :datablock, :KERNEL, :kernel, :RAMDISK, :ramdisk, :CONTEXT, :context)
    munge do |value|
      value.to_s.upcase.to_sym
    end
  end

  newproperty(:persistent, :boolean => true) do
    desc "Persistence of the image."
    defaultto :false
    newvalues(:true, :false)
  end

  newproperty(:dev_prefix) do
    desc "Prefix of device: hd, sd, xvd or vd."
  end

  newproperty(:target) do
    desc "Target to use for disk image: hda, hdb, sda, sdb"
  end

  newproperty(:path) do
    desc "Path to original image that will be copied to the image repository."
  end

  newproperty(:driver) do
    desc "Driver to use for image: KVM: raw or qcow2, XEN: tap:aio or file:"
  end

  newproperty(:disk_type) do
    desc "Type of the image (BLOCK, CDROM, RBD, FILE, KERNEL, RAMDISK or CONTEXT)"
  end

  newparam(:source) do
    desc "Source to be used in the DISK attribute. Useful for non-file based "+
      "images."
  end

  # Mandatory options for disk images with no path
  newproperty(:size) do
    desc "Size in MB."
  end

  newproperty(:fstype) do
    desc "FStype for disk."
  end

end
