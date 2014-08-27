module Puppet::Util::Opennebula::Templates
  def self.onetemplate
    <<-EOF
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
  end
end
