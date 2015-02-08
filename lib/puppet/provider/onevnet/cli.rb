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
# Deutsche Post E-POST Development GmbH - 2014, 2015
#

require 'rubygems'
require 'nokogiri'

Puppet::Type.type(:onevnet).provide(:cli) do
  desc "onevnet provider"

  has_command(:onevnet, "onevnet") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  # Create a network with onevnet by passing in a temporary template.
  def create
    file = Tempfile.new("onevnet-#{resource[:name]}")
    builder = Nokogiri::XML::Builder.new do |xml|
        xml.VNET do
            xml.NAME resource[:name]
            xml.BRIDGE resource[:bridge]
            xml.PHYDEV do
                resource[:phydev]
            end if resource[:phydev]
            xml.NETWORK_SIZE do
                resource[:network_size]
            end if resource[:network_size]
            xml.NETWORK_ADDRESS do
                resource[:network_address]
            end if resource[:network_address]
            xml.IP_START do
                resource[:network_start]
            end if resource[:network_start]
            xml.IP_END do
                resource[:network_end]
            end if resource[:network_end]
            xml.MAC_START do
                resource[:macstart]
            end if resource[:macstart]
            xml.SITE_PREFIX do
                resource[:siteprefix]
            end if resource[:siteprefix]
            xml.GLOBAL_PREFIX do
                resource[:globalprefix]
            end if resource[:globalprefix]
            xml.VLAN_ID do
                resource[:vlanid]
            end if resource[:vlanid]
            xml.CONTEXT do
                resource[:context].each do |k,v|
                    xml.send(k.upcase, v)
                end if resource[:context]
            end
        end
        # enf xml vnet do
    end
    # end builder
    tempfile = builder.to_xml
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
      vnets = Nokogiri::XML(onevnet('list','-x')).root.xpath('/VNET_POOL/VNET')
      vnets.collect do |vnet|
          new(
              :name            => vnet.xpath('./NAME').text,
              :ensure          => :present,
              :bridge          => (vnet.xpath('./TEMPLATE/BRIDGE') || vnet.xpath('./BRIDGE')).text,
              :context         => nil,
              :dnsservers      => (vnet.xpath('./TEMPLATE/DNSSERVERS').text.to_a unless vnet.xpath('./TEMPLATE/DNSSERVERS').nil?),
              :gateway         => (vnet.xpath('./TEMPLATE/GATEWAY').text unless vnet.xpath('./TEMPLATE/GATEWAY').nil?),
              :model           => (vnet.xpath('./TEMPLATE/MODEL').text unless vnet.xpath('./TEMPLATE/MODEL').nil?),
              :phydev          => (vnet.xpath('./TEMPLATE/PHYDEV') || vnet.xpath('./PHYDEV')).text,
              :vlanid          => (vnet.xpath('./TEMPLATE/VLAN_ID') || vnet.xpath('./VLAN_ID')).text,
              :network_address => (vnet.xpath('./TEMPLATE/NETWORK_ADDRESS').text unless vnet.xpath('./TEMPLATE/NETWORK_ADDRESS').nil?),
              :network_mask    => (vnet.xpath('./TEMPLATE/NETWORK_MASK').text unless vnet.xpath('./TEMPLATE/NETWORK_MASK').nil?)
          )
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
