require 'rexml/document'
require 'tempfile'
require 'erb'
require 'puppet/util/opennebula'

Puppet::Type.type(:onetemplate).provide(:onetemplate) do
  desc "onetemplate provider"

  include Puppet::Util::Opennebula::CLI
  extend Puppet::Util::Opennebula::Properties

  commands :onetemplate => "onetemplate"

  property_map :cpu     => "VMTEMPLATE/TEMPLATE/CPU",
    :memory             => "VMTEMPLATE/TEMPLATE/MEMORY",
    :vcpu               => "VMTEMPLATE/TEMPLATE/VCPU",
    :os_kernel          => "VMTEMPLATE/TEMPLATE/OS/KERNEL",
    :os_initrd          => "VMTEMPLATE/TEMPLATE/OS/INITRD",
    :os_arch            => "VMTEMPLATE/TEMPLATE/OS/ARCH",
    :os_root            => "VMTEMPLATE/TEMPLATE/OS/ROOT",
    :os_kernel_cmd      => "VMTEMPLATE/TEMPLATE/OS/KERNELCMD",
    :os_bootloader      => "VMTEMPLATE/TEMPLATE/OS/BOOTLOADER",
    :os_boot            => "VMTEMPLATE/TEMPLATE/OS/BOOT",
    :acpi               => "VMTEMPLATE/TEMPLATE/FEATURES/ACPI",
    :pae                => "VMTEMPLATE/TEMPLATE/FEATURES/PAE",
    :pci_bridge         => "VMTEMPLATE/TEMPLATE/FEATURES/PCI_BRIDGE",
    :disks              => "VMTEMPLATE/TEMPLATE/DISK/IMAGE",
    :nics               => "VMTEMPLATE/TEMPLATE/NIC/NETWORK",
    :nic_model          => "VMTEMPLATE/TEMPLATE/NIC/MODEL",
    :graphics_type      => "VMTEMPLATE/TEMPLATE/GRAPHICS/TYPE",
    :graphics_listen    => "VMTEMPLATE/TEMPLATE/GRAPHICS/LISTEN",
    :graphics_port      => "VMTEMPLATE/TEMPLATE/GRAPHICS/PORT",
    :graphics_passwd    => "VMTEMPLATE/TEMPLATE/GRAPHICS/PASSWORD",
    :graphics_keymap    => "VMTEMPLATE/TEMPLATE/GRAPHICS/KEYMAP",
    :context_ssh        => "VMTEMPLATE/TEMPLATE/CONTEXT/SSH",
    :context_ssh_pubkey => "VMTEMPLATE/TEMPLATE/CONTEXT/SSH_PUBLIC_KEY",
    :context_network    => "VMTEMPLATE/TEMPLATE/CONTEXT/NETWORK",
    :context_onegate    => "VMTEMPLATE/TEMPLATE/CONTEXT/ONEGATE",
    :context_files      => "VMTEMPLATE/TEMPLATE/CONTEXT/FILES_DS"


  # Create a VM template with onetemplate by passing in a temporary template definition file.
  def create
    content = Puppet::Util::Opennebula::Templates.onetemplate.result(binding)
    file = Tempfile.new("onetemplate-#{resource[:name]}")
    file.write content
    file.close
    self.debug "Creating template using #{content}"
    self.invoke 'create', file.path
    file.delete
  end

  # Destroy a VM using onevm delete
  def destroy
    self.invoke 'delete', resource[:name]
  end

  # Return a list of existing VM's using the onevm -x list command
  def self.onetemplate_list
    output = invoke 'list', '--xml'
    xml = REXML::Document.new(output)
    onevm = []
    xml.elements.each("VMTEMPLATE_POOL/VMTEMPLATE/NAME") do |element|
      onevm << element.text
    end
    onevm
  end

  # Check if a VM exists by scanning the onevm list
  def exists?
    self.class.onetemplate_list().include?(resource[:name])
  end

  # Return the full hash of all existing onevm resources
  def self.resources
    onetemplate_list.map do |template|
      hash = {}

      # Obvious resource attributes
      hash[:provider] = self.name.to_s
      hash[:name] = template

      hash[:disks] = []
      hash[:nics] = []
      hash[:context_files] = []

      # Open onevm xml output using REXML
      output = invoke('show', template, '--xml')
      xml = REXML::Document.new(output)

      # Traverse the XML document and populate the common attributes
      xml.elements.each("VMTEMPLATE/TEMPLATE/MEMORY") { |element|
        hash[:memory] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/CPU") { |element|
        hash[:cpu] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/VCPU") { |element|
        hash[:vcpu] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/DISK/IMAGE") { |element|
        hash[:disks] << element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/FEATURES/ACPI") { |element|
        hash[:acpi] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/GRAPHICS/KEYMAP") { |element|
        hash[:graphics_keymap] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/GRAPHICS/LISTEN") { |element|
        hash[:graphics_listen] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/GRAPHICS/TYPE") { |element|
        hash[:graphics_type] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/NIC/NETWORK") { |element|
        hash[:nics] << element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/NIC/MODEL") { |element|
        hash[:nic_model] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/OS/ARCH") { |element|
        hash[:os_arch] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/OS/BOOT") { |element|
        hash[:os_boot] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/CONTEXT/FILES_DS") { |element|
        hash[:context_files] << element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/CONTEXT/NETWORK") { |element|
        hash[:context_network] = element.text
      }
      xml.elements.each("VMTEMPLATE/TEMPLATE/CONTEXT/SSH_PUBLIC_KEY") { |element|
        hash[:context_ssh_pubkey] = element.text
      }
      new(hash)
    end
  end
  class << self
    alias instances resources
  end
  def context
  end
end
