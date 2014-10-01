require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onetemplate).provide(:cli) do
  desc "onetemplate provider"

  has_command(:onetemplate, "onetemplate") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

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

<% if resource[:os] %>
  <OS>
    <% resource[:os].each do |key, value| %>
    <<%= key.upcase %>><%= value %></<%= key.upcase %>>
    <% end %>
  </OS>
<% end %>

<% if resource[:disks] %>
<% resource[:disks].each do |disk| %>
  <DISK>
    <% disk.each do |key, value| %>
    <<%= key.upcase %>><%= value %></<%= key.upcase %>>
    <% end %>
  </DISK>
<% end %>
<% end %>

<% if resource[:nics] %>
<% resource[:nics].each do |nic| %>
  <NIC>
    <% nic.each do |key, value| %>
    <<%= key.upcase %>><%= value %></<%= key.upcase %>>
    <% end %>
  </NIC>
<% end %>
<% end %>

<% if resource[:graphics] %>
  <GRAPHICS>
    <% resource[:graphics].each do |key, value| %>
    <<%= key.upcase %>><%= value %></<%= key.upcase %>>
    <% end %>
  </GRAPHICS>
<% end %>

<% if resource[:features] %>
  <FEATURES>
    <% resource[:features].each do |key, value| %>
    <<%= key.upcase %>><%= value %></<%= key.upcase %>>
    <% end %>
  </FEATURES>
<% end %>

<% if resource[:context] %>
  <CONTEXT>
    <% resource[:context].each do |key, value| %>
    <<%= key.upcase %>><%= value %></<%= key.upcase %>>
    <% end %>
  </CONTEXT>
<% end %>

</TEMPLATE>
EOF

    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    self.debug "Creating template using #{tempfile}"
    onetemplate('create', file.path)
    file.delete
    @property_hash[:ensure] = :present
  end

  # Destroy a VM using onevm delete
  def destroy
    onetemplate('delete', resource[:name])
    @property_hash.clear
  end

  # Check if a VM exists by scanning the onevm list
  def exists?
    @property_hash[:ensure] == :present
  end

  # Return the full hash of all existing onevm resources
  def self.instances
    REXML::Document.new(onetemplate('list', '-x')).elements.collect("VMTEMPLATE_POOL/VMTEMPLATE") do |template|
      elements = template.elements
      new(
        :name     => elements["NAME"].text,
        :ensure   => :present,
        :context  => Hash[elements.collect('TEMPLATE/CONTEXT/*') { |e| [e.name.downcase, e.text] } ],
        :cpu      => (elements["TEMPLATE/CPU"].text unless elements["TEMPLATE/CPU"].nil?),
        :disks    => elements.collect("TEMPLATE/DISK") { |e| Hash[e.elements.collect { |f| [f.name.downcase, f.text] }] },
        :features => Hash[elements.collect('TEMPLATE/FEATURES/*') { |e| [e.name.downcase, { e.text => e.text, 'true' => true, 'false' => false }[e.text]] } ],
        :graphics => Hash[elements.collect('TEMPLATE/GRAPHICS/*') { |e| [e.name.downcase, e.text] } ],
        :memory   => (elements["TEMPLATE/MEMORY"].text unless elements["TEMPLATE/MEMORY"].nil?),
        :nics     => elements.collect("TEMPLATE/NIC") { |e| Hash[e.elements.collect { |f| [f.name.downcase, f.text] }] },
        :os       => Hash[elements.collect('TEMPLATE/OS/*') { |e| [e.name.downcase, e.text] } ],
        :vcpu     => (elements["TEMPLATE/VCPU"].text unless elements["TEMPLATE/VCPU"].nil?)
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

  def flush
    file = Tempfile.new('onevnet')
    file << @property_hash.map { |k, v|
      unless resource[k].nil? or resource[k].to_s.empty? or [:name, :provider, :ensure].include?(k)
        [ k.to_s.upcase, v ]
      end
    }.map{|a| "#{a[0]} = #{a[1]}" unless a.nil? }.join("\n")
    file.close
    self.debug(IO.read file.path)
    onetemplate('update', resource[:name], file.path, '--append') unless @property_hash.empty?
    file.delete
  end

end
