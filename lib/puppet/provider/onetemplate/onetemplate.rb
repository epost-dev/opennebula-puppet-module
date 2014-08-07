require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onetemplate).provide(:onetemplate) do
  desc "onetemplate provider"

  commands :onetemplate => "onetemplate"

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

  # login credentials
  def self.login
    credentials = File.read('/var/lib/one/.one/one_auth').strip.split(':')
    user = credentials[0]
    password = credentials[1]
    login = " --user #{user} --password #{password}"
    login
  end

  # getters
  def memory
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/MEMORY") { |element|
        result = element.text
      }
      result
  end
  def cpu
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/CPU") { |element|
        result = element.text
      }
      result
  end
  def vcpu
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/VCPU") { |element|
          result = element.text
      }
      result
  end
  def os_kernel
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/OS/KERNEL") { |element|
          result = element.text
      }
      result
  end
  def os_initrd
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/OS/INITRD") { |element|
          result = element.text
      }
      result
  end
  def os_arch
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/OS/ARCH") { |element|
          result = element.text
      }
      result
  end
  def os_root
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/OS/ROOT") { |element|
          result = element.text
      }
      result
  end
  def os_kernel_cmd
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/OS/KERNELCMD") { |element|
          result = element.text
      }
      result
  end
  def os_bootloader
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/OS/BOOTLOADER") { |element|
          result = element.text
      }
      result
  end
  def os_boot
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/OS/BOOT") { |element|
          result = element.text
      }
      result
  end
  def acpi
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/FEATURES/ACPI") { |element|
          result = element.text
      }
      result
  end
  def pae
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/FEATURES/PAE") { |element|
          result = element.text
      }
      result
  end
  def pci_bridge
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/FEATURES/PCI_BRIDGE") { |element|
          result = element.text
      }
      result
  end
  def disks
      result = []
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/DISK/IMAGE") { |element|
          result << element.text
      }
      result
  end
  def nics
      result = []
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/NIC/NETWORK") { |element|
          result << element.text
      }
      result
  end
  def nic_model
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/NIC/MODEL") { |element|
          result = element.text
      }
      result
  end
  def graphics_type
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/GRAPHICS/TYPE") { |element|
          result = element.text
      }
      result
  end
  def graphics_listen
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/GRAPHICS/LISTEN") { |element|
          result = element.text
      }
      result
  end
  def graphics_port
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/GRAPHICS/PORT") { |element|
          result = element.text
      }
      result
  end
  def graphics_passwd
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/GRAPHICS/PASSWORD") { |element|
          result = element.text
      }
      result
  end
  def graphics_keymap
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/GRAPHICS/KEYMAP") { |element|
          result = element.text
      }
      result
  end
  def context
      result = ''
#      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
#      xml = REXML::Document.new(`#{output}`)
#      xml.elements.each("VMTEMPLATE/TEMPLATE/CONTEXT") { |element|
#          result = element.text
#      }
      result
  end
  def context_ssh
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/CONTEXT/SSH") { |element|
          result = element.text
      }
      result
  end
  def context_ssh_pubkey
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/CONTEXT/SSH_PUBLIC_KEY") { |element|
          result = element.text
      }
      result
  end
  def context_network
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/CONTEXT/NETWORK") { |element|
          result = element.text
      }
      result
  end
  def context_onegate
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/CONTEXT/ONEGATE") { |element|
          result = element.text
      }
      result
  end
  def context_files
      result = ''
      output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VMTEMPLATE/TEMPLATE/CONTEXT/FILES_DS") { |element|
          result = element.text
      }
      result
  end
  def context_variables
      #result = ''
      #output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      #xml = REXML::Document.new(`#{output}`)
      ## todo
      #result
  end
  def context_placement_host
      #result = ''
      #output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      #xml = REXML::Document.new(`#{output}`)
      ## todo
      #result
  end
  def context_placement_cluster
      #result = ''
      #output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      #xml = REXML::Document.new(`#{output}`)
      ## todo
      #result
  end
  def context_policy
      #result = ''
      #output = "onetemplate show #{resource[:name]} --xml ", self.class.login
      #xml = REXML::Document.new(`#{output}`)
      ## todo
      #result
  end

  # setters
  def memory=(value)
      raise "Can not yet modify memory on a template"
  end
  def cpu=(value)
      raise "Can not yet modify cpu on a template"
  end
  def vcpu=(value)
      raise "Can not yet modify vcpu on a template"
  end
  def os_kernel=(value)
      raise "Can not modify kernel on a template"
  end
  def os_initrd=(value)
      raise "Can not modify initrd on a template"
  end
  def os_arch=(value)
      raise "Can not modify arch on a template"
  end
  def os_root=(value)
      raise "Can not modify root device on a template"
  end
  def os_kernel_cmd=(value)
      raise "Can not modify kernel cmd on a template"
  end
  def os_bootloader=(value)
      raise "Can not modify booloader options on a template"
  end
  def os_boot=(value)
      raise "Can not modify boot device on a template"
  end
  def acpi=(value)
      raise "Can not modify acpi on a template"
  end
  def pae=(value)
      raise "Can not modify pae on a template"
  end
  def pci_bridge=(value)
      raise "Can not modify pci_bridge on a template"
  end
  def disks=(value)
      raise "Can not yet modify disks on a template"
  end
  def nics=(value)
      #raise "Can not yet modify networks on a template"
  end
  def nic_model=(value)
      raise "Can not modify network model on a template"
  end
  def graphics_type=(value)
      raise "Can not modify graphics type on a template"
  end
  def graphics_listen=(value)
      raise "Can not yet modify graphics listen port on a template"
  end
  def graphics_port=(value)
      raise "Can not modify graphics_port on a template"
  end
  def grahics_passwd=(value)
      raise "Can not yet modify graphics password on a template"
  end
  def graphics_keymap=(value)
      raise "Can not yet modify graphics keymap on a template"
  end
  def context=(value)
      #raise "Can not yet modify context hashes on a template"
  end
  def context_ssh=(value)
      raise "Can not yet modify ssh context on a template"
  end
  def context_ssh_pubkey=(value)
      raise "Can not yet modify root ssh pub key context on a template"
  end
  def context_network=(value)
      raise "Can not yet modify network context on a template"
  end
  def context_onegate=(value)
      raise "Can not modify onegate context on a template"
  end
  def context_files=(value)
      #raise "Can not yet modify context files on a template"
  end
  def context_variables=(value)
      raise "Can not yet modify context variables on a template"
  end
  def context_placement_host=(value)
      raise "Can not yet modify host placement context on a template"
  end
  def context_placement_cluster=(value)
      raise "Can not yet modify cluster placement context on a template"
  end
  def context_policy=(value)
      raise "Can not yet modify placement policy context on a template"
  end
end
