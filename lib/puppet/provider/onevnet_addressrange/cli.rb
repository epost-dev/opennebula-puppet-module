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
require 'nokogiri' if Puppet.features.nokogiri?

Puppet::Type.type(:onevnet_addressrange).provide(:cli) do
  confine :feature => :nokogiri
  desc "onevnet provider for addressranges"

  has_command(:onevnet, "onevnet") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  # Create a network with onevnet
  def create
    file = Tempfile.new("onevnet_addressrange-#{resource[:name]}")
    File.chmod(0644, file.path)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.TEMPLATE do
        xml.AR do
            xml.TYPE resource[:protocol].to_s.upcase
            xml.SIZE resource[:ip_size].to_s
            xml.IP resource[:ip_start].to_s
            xml.MAC resource[:mac].to_s
            xml.GLOBAL_PREFIX resource[:globalprefix].to_s
            xml.ULA_PREFIX resource[:ulaprefix].to_s
            xml.PUPPET_NAME resource[:name].to_s
         end
      end
    end
    tempfile = builder.to_xml
    file.write(tempfile)
    file.close
    self.debug "Creating image using tempfile: #{tempfile}"
    onevnet('addar', resource[:onevnet_name], file.path)
    @property_hash[:ensure] = :present
  end

  # Destroy a network using onevnet delete
  def destroy
    onevnet('rmar', resource[:onevnet_name], resource[:ar_id])
    @property_hash.clear
  end

  # Check if a network_addressrange exists
  def exists?
    @property_hash[:ensure] == :present
  end

  # Return the full hash of all existing onevnet_addressrange resources for all onevnets
  def self.instances
      vnet_ar = Nokogiri::XML(onevnet('list', '-x')).root.xpath('/VNET_POOL/VNET/AR_POOL/AR/PUPPET_NAME')
#pry.binding
      vnet_ar.collect do |ar|
          new(
              :name          => ar.text,
              :ensure        => :present,
              :onevnet_name  => ar.xpath('../../../NAME').text,
              :protocol      => ar.xpath('../TYPE').text.downcase,
              :ip_size       => ar.xpath('../SIZE').text,
              :ar_id         => ar.xpath('../AR_ID').text,
              :ip_start      => (ar.xpath('../IP').text unless ar.xpath('../IP').nil?),
              :globalprefix  => (ar.xpath('../GLOBAL_PRFIX').text unless ar.xpath('../GLOBAL_PREFIX').nil?),
              :mac           => (ar.xpath('../MAC').text unless ar.xpath('../MAC').nil?),
              :ulaprefix     => (ar.xpath('../ULA_PREFIX').text unless ar.xpath('../ULA_PREFIX').nil?)
          )
      end
  end

  def self.prefetch(resources)
    vnets = instances
    resources.keys.each do |name|
      provider = vnets.find{ |vnet| vnet.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  def flush
    file = Tempfile.new('onevnet_addressrange')
    file << 'AR = ['
    file << @property_hash.map { |k, v|
      unless resource[k].nil? or resource[k].to_s.empty?
        case k
          when :ip_size
            [ 'SIZE', v ]
          when :ip_start
            [ 'IP', v ]
          when :globalprefix
            [ 'GLOBAL_PREFIX', v ]
          when :ulaprefix
            [ 'ULA_PREFIX', v ]
          when :name
            [ 'PUPPET_NAME', v ]
        end
      end
    }.map{|a| "#{a[0]} = #{a[1]}," unless a.nil? }.join("\n")
    file << "AR_ID = #{resource[:ar_id]}" unless resource[:ar_id].nil?
    file << ']'
    file.close
    self.debug(IO.read file.path)
    self.debug(@property_hash)
    unless @property_hash.empty? or resource[:ar_id].nil? or not defined? resource[:ar_id]
      onevnet('updatear', resource[:onevnet_name], resource[:ar_id], file.path)
    end
    file.delete
  end

end
