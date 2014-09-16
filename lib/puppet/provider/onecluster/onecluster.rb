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
# Deutsche Post E-POST Development GmbH - 2014
#

require 'rexml/document'

Puppet::Type.type(:onecluster).provide(:onecluster) do
  desc "onecluster provider"

  has_command(:onecluster, "onecluster") do
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
    xml = REXML::Document.new(onecluster('show', resource[:name], '-x'))
    self.debug "Removing hosts vnets and datastores from cluster #{resource[:name]}"
    xml.elements.each("CLUSTER/HOSTS/ID") { |host|
      self.debug "Removing host #{host} from cluster #{resource[:name]}"
      onecluster('delhost', resource[:name], host.text)
    }
    xml.elements.each("CLUSTER/VNETS/ID") { |vnet|
      self.debug "Removing vnet #{vnet} from cluster #{resource[:name]}"
      onecluster('delvnet', resource[:name], vnet.text)
    }
    xml.elements.each("CLUSTER/DATASTORES/ID") { |ds|
      self.debug "Removing datastore #{ds} from cluster #{resource[:name]}"
      onecluster('deldatastore', resource[:name], ds.text)
    }
    self.debug "Removing cluster #{resource[:name]}"
    onecluster('delete', resource[:name])
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end


  def self.instances
    REXML::Document.new(onecluster('list', '-x')).elements.collect("CLUSTER_POOL/CLUSTER") do |cluster|
      new(
        :name       => cluster.elements["NAME"].text,
        :ensure     => :present,
        :datastores => cluster.elements["DATASTORES"].text.to_a,
        :hosts      => cluster.elements["HOSTS"].text,
        :vnets      => cluster.elements["VNETS"].text.to_a
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
    value.each { |host|
      self.debug "Adding host #{host} to cluster #{resource[:name]}"
      onecluster('addhost', resource[:name], host)
    }
    # TODO: remove hosts which are no longer in list
  end
  def vnets=(value)
    value.each { |vnet|
      self.debug "Adding vnet #{vnet} to cluster #{resource[:name]}"
      oncluster('addvnet', resource[:name], vnet)
    }
    # TODO: remove vnets which are no longer in list
  end
  def datastores=(value)
    value.each { |datastore|
      self.debug "Adding datastore #{datastore} to cluster #{resource[:name]}"
      oncluster('adddatastore', resource[:name], datastore)
    }
    # TODO: remove datastores which are no longer in list
  end
end
