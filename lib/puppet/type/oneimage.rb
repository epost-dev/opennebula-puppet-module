Puppet::Type.newtype(:oneimage) do
  @doc = "Type for managing Images in OpenNebula using the oneimage " +
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
    desc "Name of image."

    isnamevar
  end

  newparam(:description) do
    desc "Description of image"
  end

  newparam(:type) do
    desc "Type of image: os, cdrom or datablock"
  end

  newparam(:public) do
    desc "Status of image, public or not."

    defaultto :true
  end

  newparam(:persistent) do
    desc "Persistence of the image."

    defaultto :false
  end

  newparam(:dev_prefix) do
    desc "Prefix of device: hd, sd or vd."
  end

  newparam(:bus) do
    desc "Bus to use for disk image: ide, scsi or virtio (for KVM)"
  end

  newparam(:path) do
    desc "Path to original image that will be copied to the image repository."
  end

  newparam(:source) do
    desc "Source to be used in the DISK attribute. Useful for non-file based "+
      "images."
  end

  # Mandatory options for disk images with no path
  newparam(:size) do
    desc "Size in MB."
  end

  newparam(:fstype) do
    desc "FStype for disk."
  end
end
