require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onetemplate).provide(:onetemplate) do
  desc "onetemplate provider"

  commands :onetemplate => "onetemplate"

  mk_resource_methods

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
    @property_hash[:ensure] = :present
  end

  # Destroy a VM using onevm delete
  def destroy
    output = "onetemplate delete #{resource[:name]} ", self.class.login
    `#{output}`
    @property_hash.clear
  end

  # Check if a VM exists by scanning the onevm list
  def exists?
    @property_hash[:ensure] == :present
  end

  # Return the full hash of all existing onevm resources
  def self.instances
    output = "onetemplate list -x ", login
    REXML::Document.new(`#{output}`).elements.collect("VMTEMPLATE_POOL/VMTEMPLATE") do |template|
      elements = template.elements
      new(
        :name                      => elements["NAME"].text,
        :ensure                    => :present,
        :acpi                      => (elements["TEMPLATE/FEATURES/ACPI"].text unless elements["TEMPLATE/FEATURES/ACPI"].nil?),
        :context                   => (elements["TEMPLATE/CONTEXT"].text unless elements["TEMPLATE/CONTEXT"].nil?),
        :context_files             => (elements["TEMPLATE/CONTEXT/FILES_DS"].text.to_a unless elements["TEMPLATE/CONTEXT/FILES_DS"].nil?),
        :context_network           => (elements["TEMPLATE/CONTEXT/NETWORK"].text unless elements["TEMPLATE/CONTEXT/NETWORK"].nil?),
        :context_onegate           => (elements["TEMPLATE/CONTEXT/ONEGATE"].text unless elements["TEMPLATE/CONTEXT/ONEGATE"].nil?),
        :context_placement_cluster => (elements["TEMPLATE/CONTEXT/PLACEMENT/CLUSTER"].text unless elements["TEMPLATE/CONTEXT/PLACEMENT/CLUSTER"].nil?),
        :context_placement_host    => (elements["TEMPLATE/CONTEXT/PLACEMENT/HOST"].text unless elements["TEMPLATE/CONTEXT/PLACEMENT/HOST"].nil?),
        :context_policy            => (elements["TEMPLATE/CONTEXT/POLICY"].text unless elements["TEMPLATE/CONTEXT/POLICY"].nil?),
        :context_ssh               => (elements["TEMPLATE/CONTEXT/SSH"].text unless elements["TEMPLATE/CONTEXT/SSH"].nil?),
        :context_ssh_pubkey        => (elements["TEMPLATE/CONTEXT/SSH_PUBLIC_KEY"].text unless elements["TEMPLATE/CONTEXT/SSH_PUBLIC_KEY"].nil?),
        :context_variables         => (elements["TEMPLATE/CONTEXT/VARIABLES"].text unless elements["TEMPLATE/CONTEXT/VARIABLES"].nil?),
        :cpu                       => (elements["TEMPLATE/CPU"].text unless elements["TEMPLATE/CPU"].nil?),
        :disks                     => (elements["TEMPLATE/DISK/IMAGE"].text.to_a unless elements["TEMPLATE/DISK/IMAGE"].nil?),
        :graphics_keymap           => (elements["TEMPLATE/GRAPHICS/KEYMAP"].text unless elements["TEMPLATE/GRAPHICS/KEYMAP"].nil?),
        :graphics_listen           => (elements["TEMPLATE/GRAPHICS/LISTEN"].text unless elements["TEMPLATE/GRAPHICS/LISTEN"].nil?),
        :graphics_passwd           => (elements["TEMPLATE/GRAPHICS/PASSWORD"].text unless elements["TEMPLATE/GRAPHICS/PASSWORD"].nil?),
        :graphics_port             => (elements["TEMPLATE/GRAPHICS/PORT"].text unless elements["TEMPLATE/GRAPHICS/PORT"].nil?),
        :graphics_type             => (elements["TEMPLATE/GRAPHICS/TYPE"].text unless elements["TEMPLATE/GRAPHICS/TYPE"].nil?),
        :memory                    => (elements["TEMPLATE/MEMORY"].text unless elements["TEMPLATE/MEMORY"].nil?),
        :nic_model                 => (elements["TEMPLATE/NIC/MODEL"].text unless elements["TEMPLATE/NIC/MODEL"].nil?),
        :nics                      => (elements["TEMPLATE/NIC/NETWORK"].text.to_a unless elements["TEMPLATE/NIC/NETWORK"].nil?),
        :os_arch                   => (elements["TEMPLATE/OK/ARCH"].text unless elements["TEMPLATE/OK/ARCH"].nil?),
        :os_boot                   => (elements["TEMPLATE/OK/BOOT"].text unless elements["TEMPLATE/OK/BOOT"].nil?),
        :os_bootloader             => (elements["TEMPLATE/OK/BOOTLOADER"].text unless elements["TEMPLATE/OK/BOOTLOADER"].nil?),
        :os_initrd                 => (elements["TEMPLATE/OK/INITRD"].text unless elements["TEMPLATE/OK/INITRD"].nil?),
        :os_kernel                 => (elements["TEMPLATE/OK/KERNEL"].text unless elements["TEMPLATE/OK/KERNEL"].nil?),
        :os_kernel_cmd             => (elements["TEMPLATE/OK/KERNELCMD"].text unless elements["TEMPLATE/OK/KERNELCMD"].nil?),
        :os_root                   => (elements["TEMPLATE/OK/ROOT"].text unless elements["TEMPLATE/OK/ROOT"].nil?),
        :pae                       => (elements["TEMPLATE/FEATURES/PAE"].text unless elements["TEMPLATE/FEATURES/PAE"].nil?),
        :pci_bridge                => (elements["TEMPLATE/FEATURES/PCI_BRIDGE"].text unless elements["TEMPLATE/FEATURES/PCI_BRIDGE"].nil?),
        :vcpu                      => (elements["TEMPLATE/VCPU"].text unless elements["TEMPLATE/VCPU"].nil?)
      )
    end
  end

  def self.prefetch(resources)
    templates = instances
    resources.keys.each do |name|
      if provider = templates.find{ |template| template.name == name }
        resources[name].provider = provider
      end
    end
  end

  # login credentials
  def self.login
    credentials = File.read('/var/lib/one/.one/one_auth').strip.split(':')
    user = credentials[0]
    password = credentials[1]
    login = " --user #{user} --password #{password}"
    login
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
