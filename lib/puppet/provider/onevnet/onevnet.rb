# OpenNebula Puppet provider for onevnet
#
# License: APLv2
#
# Authors:
# Based upon initial work from Ken Barber
# Modified by Martin Alfke
#
# Copyright
# initial provider had no copyright
# Deutsche Post E-POST Development GmbH - 2014
#

# require section:
# we read onevnet structure by using xml
# we write tempfiles as erb templates for creating resources and setting properties
#
require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onevnet).provide :onevnet do
  desc "onevnet provider"

  # we only define the command, but we will not use it
  # ruby seems to have an ugly way to append options to commands.
  # this is only used as a confine so we run this provider only if the command is available.
  commands :onevnet => "onevnet"

  # we can not use the mk_reosurce_methods helper.
  # opennebula has different ways of getting and reading properties.
  mk_resource_methods

  # Create a network with onevnet by passing in a temporary template.
  def create
    file = Tempfile.new("onevnet-#{resource[:name]}")
    template = ERB.new <<-EOF
NAME = "<%= resource[:name] %>"
TYPE = <%= resource[:type]%>
BRIDGE = <%= resource[:bridge] %>

<% if resource[:phydev] %>
PHYDEV = <%= resource[:phydev] %>
<% end %>
<% if resource[:type]== :fixed %>
# FIXED NETWORK
<% if resource[:leases] %>
<% resource[:leases].each { |lease| %>
LEASES = [IP=<%= lease%>]
<% } %>
<% end %>
<% elsif resource[:type]== :ranged %>
# RANGED NETWORK
<% if resource[:network_size]    %>NETWORK_MASK = <%=    resource[:network_size]    %><% end %>
<% if resource[:network_address] %>NETWORK_ADDRESS = <%= resource[:network_address] %><% end %>
<% if resource[:network_start]   %>IP_START = <%=        resource[:network_start]   %><% end %>
<% if resource[:network_end]     %>IP_END = <%=          resource[:network_end]     %><% end %>
<% if resource[:macstart]        %>MAC_START = <%=       resource[:macstart]        %><% end %>
<% if resource[:siteprefix]      %>SITE_PREFIX = <%=     resource[:siteprefix]      %><% end %>
<% if resource[:globalprefix]    %>GLOBAL_PREFIX = <%=   resource[:globalprefix]    %><% end %>
<% end %>
<% if resource[:vlanid]       %>VLAN_ID = <%=       resource[:vlanid]        %><% end %>

# Context information
<% if resource[:context] %>
<% resource[:context].each { |key,value| %>
<%= key.upcase %> = <%= value %>
<% } %>
<% end %>
EOF

    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    self.debug "Adding new network using template: #{tempfile}"
    output = "onevnet create #{file.path} ", self.class.login
    `#{output}`
    file.delete
    @property_hash[:ensure] = :present
  end

  # Destroy a network using onevnet delete
  def destroy
    output = "onevnet delete #{resource[:name]} ", self.class.login
    `#{output}`
    @property_hash.clear
  end

  # Check if a network exists by scanning the onevnet list
  def exists?
    @property_hash[:ensure] == :present
  end

  # Return the full hash of all existing onevnet resources
  def self.instances
    output = 'onevnet list -x ', login
    REXML::Document.new(`#{output}`).elements.collect('VNET_POOL/VNET') do |vnet|
      elements = vnet.elements
      hash = {
        :name            => elements['NAME'].text,
        :ensure          => :present,
        :bridge          => (elements['TEMPLATE/BRIDGE'] || elements['BRIDGE']).text,
        :context         => nil, # TODO
        :dnsservers      => (elements['TEMPLATE/DNSSERVERS'].text.to_a unless elements['TEMPLATE/DNSSERVERS'].nil?),
        :gateway         => (elements['TEMPLATE/GATEWAY'].text unless elements['TEMPLATE/GATEWAY'].nil?),
        :macstart        => '', # TODO
        :model           => (elements['TEMPLATE/MODEL'].text unless elements['TEMPLATE/MODEL'].nil?),
        :network_size    => '', # TODO
        :phydev          => (elements['TEMPLATE/PHYDEV'] || elements['PHYDEV']).text,
        :type            => elements['TYPE'].text == '0' ? 'ranged' : 'fixed',
        :vlanid          => (elements['TEMPLATE/VLAN_ID'] || elements['VLAN_ID']).text,
      }.merge(
        if elements['TYPE'].text == '0'
          {
            :globalprefix    => (elements['TEMPLATE/GLOBAL_PREFIX'] || elements['GLOBAL_PREFIX']).text,
            :network_address => elements['TEMPLATE/NETWORK_ADDRESS'].text,
            :network_end     => (elements['TEMPLATE/IP_END'] || elements['RANGE/IP_END']).text,
            :network_mask    => elements['TEMPLATE/NETWORK_MASK'].text,
            :network_start   => (elements['TEMPLATE/IP_START'] || elements['RANGE/IP_START']).text,
            :protocol        => elements['TEMPLATE/NETWORK_ADDRESS'].nil? ? :ipv6 : :ipv4,
            :siteprefix      => (elements['TEMPLATE/SITE_PREFIX'] || elements['SITE_PREFIX']).text,
          }
        elsif elements['TYPE'].text == '1'
          {
            :leases          => vnet.elements.collect('LEASES/LEASE/IP') { |e| e.text },
          }
        end
      )
      new(hash)
    end
  end

  def self.prefetch(resources)
    vnets = instances
    resources.keys.each do |name|
      if provider = vnets.find{ |vnet| vnet.name == name }
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
  def network_address=(value)
    self.debug "Setting", self.name.to_s, " address on resource onevnet #{resource[:name]} to #{value}"
    file = Tempfile.new("onevnet-network_address-#{resource[:name]}")
    template = ERB.new <<-EOF
NETWORK_ADDRESS = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    self.debug "Wrote tempfile: #{file.path} for update of ", self.name.to_s
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    self.debug "Will run #{output} to update ", self.name.to_s
    `#{output}`
    file.delete
    @property_hash[:network_address] = value
  end

  def network_mask=(value)
    self.debug "Setting netowrk mask for resource onevnet #{resource[:name]} to #{value}"
    file = Tempfile.new("onevnet-network_mask-#{resource[:name]}")
    template = ERB.new <<-EOF
NETWORK_MASK = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:network_mask] = value
  end

  def siteprefix=(value)
    file = Tempfile.new("onevnet-siteprefix-#{resource[:name]}")
    template = ERB.new <<-EOF
SITE_PREFIX = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:siteprefix] = value
  end

  def globalprefix=(value)
    file = Tempfile.new("onevnet-globalprefix-#{resource[:name]}")
    template = ERB.new <<-EOF
GLOBAL_PREFIX = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:globalprefix] = value
  end

  def dnsservers=(value)
    file = Tempfile.new("onevnet-dnsservers-#{resource[:name]}")
    template = ERB.new <<-EOF
DNSSERVERS = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:dnsservers] = value
  end

  def gateway=(value)
    file = Tempfile.new("onevnet-gateway-#{resource[:name]}")
    template = ERB.new <<-EOF
GATEWAY = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:gateway] = value
  end

  def type=(value)
    file = Tempfile.new("onevnet-type-#{resource[:name]}")
    template = ERB.new <<-EOF
TYPE = <% value.to_s.upcase == 'FIXED' ? 1 : 0 %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:type] = value
  end

  def network_start=(value)
    file = Tempfile.new("onevnet-network_start-#{resource[:name]}")
    template = ERB.new <<-EOF
IP_START = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.open
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.close
    @property_hash[:network_start] = value
  end

  def network_end=(value)
    file = Tempfile.new("onevnet-network_end-#{resource[:name]}")
    template = ERB.new <<-EOF
IP_END = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:network_end] = value
  end

  def model=(value)
    file = Tempfile.new("onevnet-model-#{resource[:name]}")
    template = ERB.new <<-EOF
MODEL = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:model] = value
  end

  def vlanid=(value)
    file = Tempfile.new("onevnet-vlanid-#{resource[:name]}")
    template = ERB.new <<-EOF
VLAN_ID = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:vlanid] = value
  end

  def bridge=(value)
    file = Tempfile.new("onevnet-bridge-#{resource[:name]}")
    template = ERB.new <<-EOF
BRIDGE = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:bridge] = value
  end

  def phydev=(value)
    file = Tempfile.new("onevnet-phydev-#{resource[:name]}")
    template = ERB.new <<-EOF
PHYDEV = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
    @property_hash[:phydev] = value
  end

  def context=(value)
    # todo
  end
end
