require 'rexml/document'
require 'tempfile'
require 'erb'
require 'puppet/util/opennebula'

Puppet::Type.type(:onetemplate).provide(:onetemplate) do
  desc "onetemplate provider"
  extend Puppet::Util::Opennebula::CLI
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
    file = Tempfile.new("onetemplate-#{resource[:name]}")
    template = ERB.new <<-EOF
<TEMPLATE>
  <NAME><%=   resource[:name]   %></NAME>
  <MEMORY><%= resource[:memory] %></MEMORY>
  <CPU><%=    resource[:cpu]    %></CPU>
  <VCPU><%=   resource[:vcpu]   %></VCPU>

  <OS>
<% if resource[:os_kernel]     %>    <KERNEL><%=     resource[:os_kernel]     %></KERNEL><% end %>
<% if resource[:os_initrd]     %>    <INITRD><%=     resource[:os_initrd]     %></INITRD><% end %>
<% if resource[:os_arch]       %>    <ARCH><%=       resource[:os_arch]       %></ARCH><% end %>
<% if resource[:os_root]       %>    <ROOT><%=       resource[:os_root]       %></ROOT><% end %>
<% if resource[:os_kernel_cmd] %>    <KERNEL_CMD><%= resource[:os_kernel_cmd] %></KERNEL_CMD><% end %>
<% if resource[:os_bootloader] %>    <BOOTLOADER><%= resource[:os_bootloader] %></BOOTLOADER><% end %>
<% if resource[:os_boot]       %>    <BOOT><%=       resource[:os_boot]       %></BOOT><% end %>
  </OS>

  <DISK>
<% resource[:disks].each do |disk| %>
    <IMAGE><%= disk %></IMAGE>
<% end %>
  </DISK>
<% resource[:nics].each do |nic| %>
  <NIC>
    <% if resource[:nic_model] %><MODEL><%= resource[:nic_model] %></MODEL><% end %>
    <NETWORK><%= nic %></NETWORK>
  </NIC>
<% end %>

  <GRAPHICS>
<% if resource[:graphics_type]   %><TYPE><%=   resource[:graphics_type]   %></TYPE><% end %>
<% if resource[:graphics_listen] %><LISTEN><%= resource[:graphics_listen] %></LISTEN><% end %>
<% if resource[:graphics_port]   %><PORT><%=   resource[:graphics_port]   %></PORT><% end %>
<% if resource[:graphics_passwd] %><PASSWD><%= resource[:graphics_passwd] %></PASSWD><% end %>
<% if resource[:graphics_keymap] %><KEYMAP><%= resource[:graphics_keymap] %></KEYMAP><% end %>
  </GRAPHICS>
  <FEATURES>
<% if resource[:acpi] %><ACPI><%= resource[:acpi] %></ACPI><% end %>
<% if resource[:pae]  %><PAE><%=  resource[:pae]  %></PAE><%  end %>
  </FEATURES>
  <CONTEXT>
<% if resource[:context_network] %><NETWORK><%= resource[:context_network] %></NETWORK><% end %>
<% if resource[:context_files] %>
    <FILES_DS><% resource[:context_files].each do |context_file| %>$FILE[IMAGE="<%= context_file %>"] <% end %></FILES_DS>
<% end %>
<% if resource[:context] %>
<% resource[:context].each do |key, value| %>
   <<%= key %>><%= value %></<%= key %>>
<% end %>
<% end %>
<% if resource[:context_ssh_pubkey] %><SSH_PUBLIC_KEY><%= resource[:context_ssh_pubkey] %></SSH_PUBLIC_KEY><% end %>
  </CONTEXT>
</TEMPLATE>
EOF

    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    self.debug "Creating template using #{tempfile}"
    output = "onetemplate create #{file.path} ", self.class.login
    `#{output}`
    file.delete
  end

  # Destroy a VM using onevm delete
  def destroy
    output = "onetemplate delete #{resource[:name]} ", self.class.login
    `#{output}`
  end

  # Return a list of existing VM's using the onevm -x list command
  def self.onetemplate_list
    output = "onetemplate list --xml ", login
    xml = REXML::Document.new(`#{output}`)
    onevm = []
    xml.elements.each("VMTEMPLATE_POOL/VMTEMPLATE/NAME") do |element|
      onevm << element.text
    end
    onevm
  end

  # Check if a VM exists by scanning the onevm list
  def exists?
    if self.class.onetemplate_list().include?(resource[:name])
        self.debug "Found template #{resource[:name]}"
        true
    end
  end

  # Return the full hash of all existing onevm resources
  def self.instances
    instances = []
    onetemplate_list.each do |template|
      hash = {}

      # Obvious resource attributes
      hash[:provider] = self.name.to_s
      hash[:name] = template

      # Open onevm xml output using REXML
      output = "onetemplate show #{template} --xml ", login
      xml = REXML::Document.new(`#{output}`)

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
        hash[:graphics_listen] = elemetn.text
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

      instances << new(hash)
    end

    instances
  end
end
