# OpenNebula Puppet provider for onecluster
#
# License: APLv2
#
# Authors:
# Based upon initial work from Ken Barber
# Modified by Martin Alfke
#
# Copyright
# initial provider had no copyright
# Deutsche Post E-POST Development GmbH - 2014,2015
#

require 'rubygems'
require 'nokogiri' if Puppet.features.nokogiri?

Puppet::Type.type(:onecluster).provide(:cli) do
  confine :feature => :nokogiri
  desc "onecluster provider"

  has_command(:onecluster, "onecluster") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  has_command(:onedatastore, "onedatastore") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  has_command(:onehost, "onehost") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  has_command(:onevnet, "onevnet") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  def create
    onecluster('create', resource[:name])
    self.debug "We have hosts: #{resource[:hosts]}"
    self.debug "We have vnets: #{resource[:vnets]}"
    resource[:hosts].each { |host|
      self.debug "Adding host #{host} to cluster #{resource[:name]}"
      onecluster('addhost', resource[:name], host)
    }
    resource[:vnets].each { |vnet|
      self.debug "Adding vnet #{vnet} to cluster #{resource[:name]}"
      onecluster('addvnet', resource[:name], vnet)
    }
    resource[:datastores].each { |datastore|
      self.debug "Adding datastore #{datastore} to cluster #{resource[:name]}"
      onecluster('adddatastore', resource[:name], datastore)
    }
    @property_hash[:ensure] = :present
  end

  def destroy
    resource[:hosts].each do |host|
      onecluster('delhost', resource[:name], host)
    end
    resource[:vnets].each do |vnet|
      onecluster('delvnet', resource[:name], vnet)
    end
    resource[:datastores].each do |datastore|
      onecluster('deldatastore', resource[:name], datastore)
    end
    onecluster('delete', resource[:name])
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end


  def self.instances
    clusters = Nokogiri::XML(onecluster('list', '-x')).root.xpath('/CLUSTER_POOL/CLUSTER')
    clusters.collect do |cluster|
      datastores = cluster.xpath('DATASTORES/ID').collect do |datastore|
        Nokogiri::XML(onedatastore('show', datastore.text, '-x')).root.xpath('/DATASTORE/NAME').text
      end
      hosts = cluster.xpath('HOSTS/ID').collect do |host|
        Nokogiri::XML(onehost('show', host.text, '-x')).root.xpath('/HOST/NAME').text
      end
      vnets = cluster.xpath('VNETS/ID').collect do |vnet|
        Nokogiri::XML(onevnet('show', vnet.text, '-x')).root.xpath('/VNET/NAME').text
      end
      new(
        :name       => cluster.xpath('./NAME').text,
        :ensure     => :present,
        :datastores => datastores,
        :hosts      => hosts,
        :vnets      => vnets
      )
    end
  end

  def self.prefetch(resources)
    clusters = instances
    resources.keys.each do |name|
      provider = clusters.find{ |cluster| cluster.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  #setters
  def hosts=(value)
    hosts = @property_hash[:hosts] || []
    (hosts - value).each do |host|
      onecluster('delhost', resource[:name], host)
    end
    (value - hosts).each do |host|
      onecluster('addhost', resource[:name], host)
    end
  end
  def vnets=(value)
    vnets = @property_hash[:vnets] || []
    (vnets - value).each do |vnet|
      onecluster('delvnet', resource[:name], vnet)
    end
    (value - vnets).each do |vnet|
      onecluster('addvnet', resource[:name], vnet)
    end
  end
  def datastores=(value)
    datastores = @property_hash[:datastores] || []
    (datastores - value).each do |datastore|
      onecluster('deldatastore', resource[:name], datastore)
    end
    (value - datastores).each do |datastore|
      onecluster('adddatastore', resource[:name], datastore)
    end
  end
end
