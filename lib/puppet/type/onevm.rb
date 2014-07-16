Puppet::Type.newtype(:onevm) do
  @doc = "Type for managing virtual machines in OpenNebula using the onevm" +
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
    desc "Name of virtual machine."

    isnamevar
  end

  newparam(:memory) do
    desc "Memory allocation for VM in megabytes."
  end

  newparam(:cpu) do
    desc "Percentage of CPU divided by 100 required for the Virtual Machine. " +
      "Half a processor is written 0.5."
  end

  newparam(:vcpu) do
    desc "Virtual CPUs"
  end

  newparam(:os_kernel) do
    desc "Path to the OS kernel to boot the image. Required in Xen."
  end

  newparam(:os_arch) do
    desc "CPU architecture."
  end

  newparam(:os_initrd) do
    desc "Path to the initrd image."
  end

  newparam(:os_root) do
    desc "Device to be mounted as root."
  end

  newparam(:os_kernel_cmd) do
    desc "Arguments for the booting kernel."
  end

  newparam(:os_bootloader) do
    desc "Path to the bootloader executable."
  end

  newparam(:os_boot) do
    desc "Boot device type: hd,fd,cdrom,network"
  end

  newparam(:disks) do
    desc "Array of disk definitions."
  end

  newparam(:nics) do
    desc "Array of nic definitions."
  end

  newparam(:graphics_type) do
    desc "Graphics type - vnc or sdl"

    defaultto "vnc"
  end

  newparam(:graphics_listen) do
    desc "IP to listen on."

    defaultto "127.0.0.1"
  end

  newparam(:graphics_port) do
    desc "Port for the VNC server. If left empty this is automatically set."
  end

  newparam(:graphics_passwd) do
    desc "VNC password."
  end

  newparam(:graphics_keymap) do
    desc "keyboard configuration locale to use in the VNC display"
  end

  newparam(:context) do
    desc "Pass context hash to vm."
  end
end
