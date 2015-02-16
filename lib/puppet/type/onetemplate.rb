# OpenNebula Puppet type for onetemplate
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
Puppet::Type.newtype(:onetemplate) do
  @doc = "Type for managing templates in OpenNebula using the onevm" +
         "wrapper command."

  ensurable

  # Capacity Section
  newparam(:name, :namevar => true) do
    desc "Name of template."
    validate do |value|
      fail("Invalid name: #{value}") unless value =~ /^([A-Za-z]).*/
    end
  end

  newproperty(:description) do
    desc "Description of template."
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

  # OS and Boot Options Section
  newproperty(:os) do
    desc "A hash for OS and Boot Options Section"
    defaultto {}
    validate do |value|
      # TODO: validate each key
      valid_keys = [
        'arch',
        'machine',
        'kernel',
        'kernel_ds',
        'initrd',
        'initrd_ds',
        'root',
        'kernel_cmd',
        'bootloader',
        'boot',
      ]
      fail "#{(value.keys - valid_keys).join(' and ')} is not one of #{valid_keys.join(' or ')}" unless (value.keys - valid_keys).empty?
    end
  end

  # OS booting template config
  # Kernel section
  newproperty(:os_kernel) do
    desc "Path to the OS kernel to boot the template. Required in Xen."
    validate do |value|
      Puppet.deprecation_warning('os_kernel is deprecated, please use os hash instead.')
    end
    munge do |value|
      resource[:os] ||= {}
      resource[:os]['kernel'] = value
      nil
    end
  end

  # Ramdisk section
  newproperty(:os_initrd) do
    desc "Path to the initrd image."
    validate do |value|
      Puppet.deprecation_warning('os_initrd is deprecated, please use os hash instead.')
    end
    munge do |value|
      resource[:os] ||= {}
      resource[:os]['initrd'] = value
      nil
    end
  end

  # Boot section
  newproperty(:os_arch) do
    desc "CPU architecture."
    validate do |value|
      Puppet.deprecation_warning('os_arch is deprecated, please use os hash instead.')
    end
    munge do |value|
      resource[:os] ||= {}
      resource[:os]['arch'] = value
      nil
    end
  end

  newproperty(:os_root) do
    desc "Device to be mounted as root."
    validate do |value|
      Puppet.deprecation_warning('os_root is deprecated, please use os hash instead.')
    end
    munge do |value|
      resource[:os] ||= {}
      resource[:os]['root'] = value
      nil
    end
  end

  newproperty(:os_kernel_cmd) do
    desc "Arguments for the booting kernel."
    validate do |value|
      Puppet.deprecation_warning('os_kernel_cmd is deprecated, please use os hash instead.')
    end
    munge do |value|
      resource[:os] ||= {}
      resource[:os]['kernel_cmd'] = value
      nil
    end
  end

  newproperty(:os_bootloader) do
    desc "Path to the bootloader executable."
    validate do |value|
      Puppet.deprecation_warning('os_bootloader is deprecated, please use os hash instead.')
    end
    munge do |value|
      resource[:os] ||= {}
      resource[:os]['bootloader'] = value
      nil
    end
  end

  newproperty(:os_boot) do
    desc "Boot device type: hd,fd,cdrom,network"
    validate do |value|
      Puppet.deprecation_warning('os_boot is deprecated, please use os hash instead.')
    end
    munge do |value|
      resource[:os] ||= {}
      resource[:os]['boot'] = value
      nil
    end
  end

  # Features Section
  newproperty(:features) do
    desc "A hash for Features Section"
    defaultto {}
    validate do |value|
      # TODO: validate each key
      valid_keys = [
        'pae',
        'acpi',
        'apic',
        'localtime',
        'hyperv',
        'device_mode',
        'pci_bridge',
      ]
      fail "#{(value.keys - valid_keys).join(' and ')} is not one of #{valid_keys.join(' or ')}" unless (value.keys - valid_keys).empty?
    end
  end

  # Features section
  newproperty(:acpi, :boolean => true) do
    desc "Enable ACPI"
    newvalues(:true, :false)
    validate do |value|
      Puppet.deprecation_warning('acpi is deprecated, please use features hash instead.')
    end
    munge do |value|
      resource[:features] ||= {}
      resource[:features]['acpi'] = value
      nil
    end
  end

  newproperty(:pae, :boolean => true) do
    desc "Enable PAE"
    newvalues(:true, :false)
    validate do |value|
      Puppet.deprecation_warning('pae is deprecated, please use features hash instead.')
    end
    munge do |value|
      resource[:features] ||= {}
      resource[:features]['pae'] = value
      nil
    end
  end

  newproperty(:pci_bridge, :boolean => true) do
    desc "PCI Bridging"
    newvalues(:true, :false)
    validate do |value|
      Puppet.deprecation_warning('pci_bridge is deprecated, please use features hash instead.')
    end
    munge do |value|
      resource[:features] ||= {}
      resource[:features]['pci_bridge'] = value
      nil
    end
  end

  # Disks Section
  newproperty(:disks, :array_matching => :all) do
    desc "An array of hash for Disks Section"
    defaultto []
    validate do |value|
      if value.is_a?( Hash)
        # TODO: validate for either persistent or volatile disk and each key
        valid_keys = [
          # Persistent and Clone Disks
          'image_id',
          'image',
          'image_uid',
          'image_uname',
          'dev_prefix',
          'target',
          'driver',
          'cache',
          'readonly',
          'io',
          # Volatile DISKS
          'type',
          'size',
          'format',
          'dev_prefix',
          'target',
          'driver',
          'cache',
          'readonly',
          'io',
        ]
        fail "#{(value.keys - valid_keys).join(' and ')} is not one of #{valid_keys.join(' or ')}" unless (value.keys - valid_keys).empty?
      end
    end
    munge do |value|
      if ! value.is_a?(Hash)
        Puppet.deprecation_warning('disks should be a hash.')
        {
          'image' => value
        }
      else
        value
      end
    end
  end

  # Network Section
  newproperty(:nics, :array_matching => :all) do
    desc "An array of hash for Network Section"
    defaultto []
    validate do |value|
      if value.is_a?(Hash)
        # TODO: validate each key
        valid_keys = [
          'network_id',
          'network',
          'network_uid',
          'network_uname',
          'ip',
          'mac',
          'bridge',
          'target',
          'script',
          'model',
          'white_ports_tcp',
          'black_ports_tcp',
          'white_ports_udp',
          'black_ports_udp',
          'icmp',
        ]
        fail "#{(value.keys - valid_keys).join(' and ')} is not one of #{valid_keys.join(' or ')}" unless (value.keys - valid_keys).empty?
      end
    end
    munge do |value|
      if ! value.is_a?(Hash)
        Puppet.deprecation_warning('nics should be a hash.')
        {
          'network' => value
        }
      else
        value
      end
    end
  end

  newproperty(:nic_model) do
    desc "Model to use for all network interfaces" +
      "e.g. virtio for kvm"
    validate do |value|
      Puppet.deprecation_warning('nic_model is deprecated, please use nics hash instead.')
    end
  end

  # I/O Devices Section
  newproperty(:graphics) do
    desc "A hash for I/O Devices Section"
    defaultto {}
    validate do |value|
      # TODO: validate each key
      valid_keys = [
        'type',
        'listen',
        'port',
        'passwd',
        'keymap',
      ]
      fail "#{(value.keys - valid_keys).join(' and ')} is not one of #{valid_keys.join(' or ')}" unless (value.keys - valid_keys).empty?
    end
  end

  newproperty(:graphics_type) do
    desc "Graphics type - vnc or sdl"

    defaultto "vnc"
    validate do |value|
      Puppet.deprecation_warning('graphics_type is deprecated, please use graphics hash instead.')
    end
    munge do |value|
      resource[:graphics] ||= {}
      resource[:graphics]['type'] = value
      nil
    end
  end

  newproperty(:graphics_listen) do
    desc "IP to listen on."

    defaultto "0.0.0.0"
    validate do |value|
      Puppet.deprecation_warning('graphics_listen is deprecated, please use graphics hash instead.')
    end
    munge do |value|
      resource[:graphics] ||= {}
      resource[:graphics]['listen'] = value
      nil
    end
  end

  newproperty(:graphics_port) do
    desc "Port for the VNC server. If left empty this is automatically set."
    validate do |value|
      Puppet.deprecation_warning('graphics_port is deprecated, please use graphics hash instead.')
    end
    munge do |value|
      resource[:graphics] ||= {}
      resource[:graphics]['port'] = value
      nil
    end
  end

  newproperty(:graphics_passwd) do
    desc "VNC password."
    validate do |value|
      Puppet.deprecation_warning('graphics_passwd is deprecated, please use graphics hash instead.')
    end
    munge do |value|
      resource[:graphics] ||= {}
      resource[:graphics]['passwd'] = value
      nil
    end
  end

  newproperty(:graphics_keymap) do
    desc "keyboard configuration locale to use in the VNC display"
    validate do |value|
      Puppet.deprecation_warning('graphics_keymap is deprecated, please use graphics hash instead.')
    end
    munge do |value|
      resource[:graphics] ||= {}
      resource[:graphics]['keymap'] = value
      nil
    end
  end

  # Context Section
  newproperty(:context) do
    desc "Pass context hash to vm."
    defaultto {}
  end

  # network & SSH section
  newproperty(:context_ssh) do
    desc "Activate SSH contextualization"
    munge do |value|
      resource[:context] ||= {}
      resource[:context]['ssh'] = value
      nil
    end
  end

  newproperty(:context_ssh_pubkey) do
    desc "Root SSH pub key contextualization"
    munge do |value|
      resource[:context] ||= {}
      resource[:context]['ssh_pubkey'] = value
      nil
    end
  end

  newproperty(:context_network) do
    desc "Activate network contextualization"
    munge do |value|
      resource[:context] ||= {}
      resource[:context]['network'] = value
      nil
    end
  end

  newproperty(:context_onegate) do
    desc "Activate OneGate token in contextualization"
    munge do |value|
      resource[:context] ||= {}
      resource[:context]['onegate'] = value
      nil
    end
  end

  # Files section
  newproperty(:context_files, :array_matching => :all) do
    desc "Array of additional contextualization files"
    munge do |value|
      resource[:context] ||= {}
      resource[:context]['files'] = value
      nil
    end
  end

  newproperty(:context_variables) do
    desc "Hash of additional contextualization variables"
    munge do |value|
      resource[:context] ||= {}
      resource[:context].merge!(value)
      nil
    end
  end

  # Template Scheduling config
  # placement section
  newproperty(:context_placement_host) do
    desc "Host where to place the vm using this template"
    munge do |value|
      resource[:context] ||= {}
      resource[:context]['placement_host'] = value
      nil
    end
  end

  newproperty(:context_placement_cluster) do
    desc "Cluster where to place the vm using this template"
    munge do |value|
      resource[:context] ||= {}
      resource[:context]['placement_cluster'] = value
      nil
    end
  end

  # policy section
  newproperty(:context_policy) do
    desc "Activate policy how to distribute vm using this template"
    munge do |value|
      resource[:context] ||= {}
      resource[:context]['policy'] = value
      nil
    end
  end

end
