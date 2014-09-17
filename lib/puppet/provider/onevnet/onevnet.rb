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

  has_command(:onevnet, "onevnet") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

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
    onevnet('create', file.path)
    file.delete
    @property_hash[:ensure] = :present
  end

  # Destroy a network using onevnet delete
  def destroy
    onevnet('delete', resource[:name])
    @property_hash.clear
  end

  # Check if a network exists by scanning the onevnet list
  def exists?
    @property_hash[:ensure] == :present
  end

  # Return the full hash of all existing onevnet resources
  def self.instances
    REXML::Document.new(onevnet('list', '-x')).elements.collect('VNET_POOL/VNET') do |vnet|
      elements = vnet.elements
      hash = {
        :name            => elements['NAME'].text,
        :ensure          => :present,
        :bridge          => (elements['TEMPLATE/BRIDGE'] || elements['BRIDGE']).text,
        :context         => nil, # TODO
        :dnsservers      => (elements['TEMPLATE/DNSSERVERS'].text.to_a unless elements['TEMPLATE/DNSSERVERS'].nil?),
        :gateway         => (elements['TEMPLATE/GATEWAY'].text unless elements['TEMPLATE/GATEWAY'].nil?),
        :macstart        => (elements['TEMPLATE/MACSTART'].text unless elements['TEMPLATE/MACSTART'].nil?),
        :model           => (elements['TEMPLATE/MODEL'].text unless elements['TEMPLATE/MODEL'].nil?),
        :network_size    => (elements['TEMPLATE/NETWORK_SIZE'].text unless elements['TEMPLATE/NETWORK_SIZE'].nil?),
        :phydev          => (elements['TEMPLATE/PHYDEV'] || elements['PHYDEV']).text,
        :type            => elements['TYPE'].text == '0' ? 'ranged' : 'fixed',
        :vlanid          => (elements['TEMPLATE/VLAN_ID'] || elements['VLAN_ID']).text,
      }.merge(
        if elements['TYPE'].text == '0'
          {
            :globalprefix    => (elements['TEMPLATE/GLOBAL_PREFIX'] || elements['GLOBAL_PREFIX']).text,
            :network_address => (elements['TEMPLATE/NETWORK_ADDRESS'].text unless elements['TEMPLATE/NETWORK_ADDRESS'].nil?),
            :network_end     => (elements['TEMPLATE/IP_END'] || elements['RANGE/IP_END']).text,
            :network_mask    => (elements['TEMPLATE/NETWORK_MASK'].text unless elements['TEMPLATE/NETWORK_MASK'].nil?),
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

  def flush
    file = Tempfile.new('onevnet')
    file << @property_hash.map { |k, v|
      unless resource[k].nil? or resource[k].to_s.empty? or [:name, :provider, :ensure].include?(k)
        case k
        #when :dnsservers
        when :network_end
          [ 'IP_END', v ]
        when :network_start
          [ 'IP_START', v ]
        when :type
          # Is it really updatable ?
          v.to_s.upcase == 'FIXED' ? 1 : 0
        when :vlanid
          [ 'VLAN_ID', v ]
        else
          [ k.to_s.upcase, v ]
        end
      end
    }.map{|a| "#{a[0]} = #{a[1]}" unless a.nil? }.join("\n")
    file.close
    self.debug(IO.read file.path)
    onevnet('update', resource[:name], file.path, '--append') unless @property_hash.empty?
    file.delete
  end

end
