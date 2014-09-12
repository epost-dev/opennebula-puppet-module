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

  commands :onecluster => "onecluster"

  mk_resource_methods

  def create
    output = "onecluster create #{resource[:name]} ", self.class.login()
    `#{output}`
    self.debug "We have hosts: #{resource[:hosts]}"
    self.debug "We have vnets: #{resource[:vnets]}"
    hosts = []
    hosts << resource[:hosts]
    hosts.each { |host|
      host_command = "onecluster addhost #{resource[:name]} #{host} ", self.class.login()
      self.debug "Running host add command : #{host_command}"
      `#{host_command}`
    }
    vnets = []
    vnets << resource[:vnets]
    vnets.each { |vnet|
        vnet_command = "onecluster addvnet #{resource[:name]} #{vnet} ", self.class.login()
        self.debug "Running vnet add command: #{vnet_command}"
        `#{vnet_command}`
    }
    ds = []
    ds << resource[:datastores]
    ds.each { |datastore|
        ds_command = "onecluster adddatastore #{resource[:name]} #{datastore} ", self.class.login()
        `#{ds_command}`
    }
    @property_hash[:ensure] = :present
  end

  def destroy
      hosts_output = "onecluster show #{resource[:name]} --xml ", self.class.login()
      xml = REXML::Document.new(`#{hosts_output}`)
      self.debug "Removing hosts vnets and datastores from cluster #{resource[:name]}"
      xml.elements.each("CLUSTER/HOSTS/ID") { |host|
          host_command = "onecluster delhost #{resource[:name]} #{host.text} ", self.class.login
          `#{host_command}`
      }
      xml.elements.each("CLUSTER/VNETS/ID") { |vnet|
          vnet_command = "onecluster delvnet #{resource[:name]} #{vnet.text} ", self.class.login
          `#{vnet_command}`
      }
      xml.elements.each("CLUSTER/DATASTORES/ID") { |ds|
          ds_command = "onecluster deldatastore #{resource[:name]} #{ds.text} ", self.class.login
          `#{ds_command}`
      }
      output = "onecluster delete #{resource[:name]} ", self.class.login()
      self.debug "Running command #{output}"
      `#{output}`
      @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end


  def self.instances
    output = "onecluster list -x ", login
    REXML::Document.new(`#{output}`).elements.collect("CLUSTER_POOL/CLUSTER") do |cluster|
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

  # login credentials
  def self.login
    credentials = File.read('/var/lib/one/.one/one_auth').strip.split(':')
    user = credentials[0]
    password = credentials[1]
    login = " --user #{user} --password #{password}"
    login
  end

  #setters
  def hosts=(value)
      value.each { |host|
        host_command = "onecluster addhost #{resource[:name]} #{host} ", self.class.login()
        self.debug "Running host add command : #{host_command}"
        `#{host_command}`
      }
      # todo: remove hosts which are no longer in list
  end
  def vnets=(value)
      value.each { |vnet|
        vnet_command = "onecluster addvnet #{resource[:name]} #{vnet} ", self.class.login()
        self.debug "Running vnet add command: #{vnet_command}"
        `#{vnet_command}`
      }
      # todo: remove vnets which are no longer in list
  end
  def datastores=(value)
      value.each { |ds|
        ds_command = "onecluster adddatastore #{resource[:name]} #{datastore} ", self.class.login()
        `#{ds_command}`
      }
      # todo: remove datastores which are no longer in list
  end
end
