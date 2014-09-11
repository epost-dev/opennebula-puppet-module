Puppet::Type.newtype(:onetemplate) do
  @doc = "Type for managing templates in OpenNebula using the onevm" +
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

  # General template config
  newparam(:name, :namevar => true) do
    desc "Name of template."
    validate do |value|
        fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:memory) do
    desc "Memory allocation for template in megabytes."
  end

  newproperty(:cpu) do
    desc "Percentage of CPU divided by 100 required for the Virtual Machine. " +
      "Half a processor is written 0.5."
  end

  newproperty(:vcpu) do
    desc "Virtual CPUs"
  end

  # OS booting template config
  # Kernel section
  newproperty(:os_kernel) do
    desc "Path to the OS kernel to boot the template. Required in Xen."
  end

  # Ramdisk section
  newproperty(:os_initrd) do
    desc "Path to the initrd image."
  end

  # Boot section
  newproperty(:os_arch) do
    desc "CPU architecture."
  end

  newproperty(:os_root) do
    desc "Device to be mounted as root."
  end

  newproperty(:os_kernel_cmd) do
    desc "Arguments for the booting kernel."
  end

  newproperty(:os_bootloader) do
    desc "Path to the bootloader executable."
  end

  newproperty(:os_boot) do
    desc "Boot device type: hd,fd,cdrom,network"
  end

  # Features section
  newproperty(:acpi) do
      desc "Enable ACPI"
  end

  newproperty(:pae) do
      desc "Enable PAE"
  end

  newproperty(:pci_bridge) do
      desc "PCI Bridging"
  end

  # Template Storage config
  newproperty(:disks, :array_matching => :all) do
    desc "Array of disk definitions."
  end

  # Template Network config
  newproperty(:nics, :array_matching => :all) do
    desc "Array of nic definitions."
  end

  newproperty(:nic_model) do
      desc "Model to use for all network interfaces" +
          "e.g. virtio for kvm"
  end

  # Template Input/Output config
  newproperty(:graphics_type) do
    desc "Graphics type - vnc or sdl"

    defaultto "vnc"
  end

  newproperty(:graphics_listen) do
    desc "IP to listen on."

    defaultto "0.0.0.0"
  end

  newproperty(:graphics_port) do
    desc "Port for the VNC server. If left empty this is automatically set."
  end

  newproperty(:graphics_passwd) do
    desc "VNC password."
  end

  newproperty(:graphics_keymap) do
    desc "keyboard configuration locale to use in the VNC display"
  end

  # Template Context config
  # generic context
  newproperty(:context) do
    desc "Pass context hash to vm."
  end

  # network & SSH section
  newproperty(:context_ssh) do
      desc "Activate SSH contextualization"
  end

  newproperty(:context_ssh_pubkey) do
      desc "Root SSH pub key contextualization"
  end

  newproperty(:context_network) do
      desc "Activate network contextualization"
  end

  newproperty(:context_onegate) do
      desc "Activate OneGate token in contextualization"
  end

  # Files section
  newproperty(:context_files, :array_matching => :all) do
      desc "Array of additional contextualization files"
  end

  newproperty(:context_variables) do
      desc "Hash of additional contextualization variables"
  end

  # Template Scheduling config
  # placement section
  newproperty(:context_placement_host) do
      desc "Host where to place the vm using this template"
  end

  newproperty(:context_placement_cluster) do
      desc "Cluster where to place the vm using this template"
  end

  # policy section
  newproperty(:context_policy) do
      desc "Activate policy how to distribute vm using this template"
  end

end
