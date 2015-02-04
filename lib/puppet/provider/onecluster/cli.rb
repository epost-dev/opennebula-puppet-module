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

require 'rexml/document'

Puppet::Type.type(:onecluster).provide(:cli) do
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
    clusters = REXML::Document.new(onecluster('list', '-x')).elements.collect("CLUSTER_POOL/CLUSTER")
    clusters.collect do |cluster|
      datastores = cluster.elements.collect("DATASTORES/ID") do |id|
        REXML::Document.new(onedatastore('show', id.text, '-x')).elements["DATASTORE/NAME"].text
      end
      hosts = cluster.elements.collect("HOSTS/ID") do |id|
        REXML::Document.new(onehost('show', id.text, '-x')).elements["HOST/NAME"].text
      end
      vnets = cluster.elements.collect("VNETS/ID") do |id|
        REXML::Document.new(onevnet('show', id.text, '-x')).elements["VNET/NAME"].text
      end
      new(
        :name       => cluster.elements["NAME"].text,
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
      if provider = clusters.find{ |cluster| cluster.name == name }
        resources[name].provider = provider
      end
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
