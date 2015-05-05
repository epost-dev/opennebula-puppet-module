# OpenNebula Puppet provider for onevnet addressranges
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

#require 'pry'

require 'rubygems'
require 'nokogiri'

Puppet::Type.type(:onevnet_addressrange).provide(:cli) do
  desc "onevnet provider"

  has_command(:onevnet, "onevnet") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  # Create a network with onevnet
  def create
    onevnet('addar', resource[:onevnet])
    @property_hash[:ensure] = :present
  end

  # Destroy a network using onevnet delete
  def destroy
    onevnet('rmar', resource[:onevnet], resource[:ar_id])
    @property_hash.clear
  end

  # Check if a network exists by scanning the addressranges of the given onevnet
  def exists?
    @property_hash[:ensure] == :present
  end

  # Return the full hash of all existing onevnet_addressrange resources for a given onevnet
  def self.instances
      vnet_ar = Nokogiri::XML(onevnet('show', resource[:onevnet], '-x')).root.xpath('/VNET/AR_POOL')
#pry.binding
      vnet_ar.collect do |ar|
          new(
              :name          => ar.xpath('./AR/PUPPET_AR_NAME').text,
              :ensure        => :present,
              :type          => ar.xpath('./AR/TYPE').text,
              :ip_size       => ar.xpath('./AR/SIZE').text,
              :ar_id         => ar.xpath('./AR/AR_ID').text,
              :ip_start      => (ar.xpath('./AR/IP').text unless ar.xpath('./AR/IP').nil?),
              :globalprefix  => (ar.xpath('./AR/GLOBAL_PRFIX').text unless ar.xpath('./AR/GLOBAL_PREFIX').nil?),
              :mac           => (ar.xpath('./AR/MAC').text unless ar.xpath('./AR/MAC').nil?),
              :ulaprefix     => (ar.xpath('./AR/ULA_PREFIX').text unless ar.xpath('./AR/ULA_PREFIX').nil?)
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
