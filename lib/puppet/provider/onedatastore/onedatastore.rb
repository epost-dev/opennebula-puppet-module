# OpenNebula Puppet provider for onedatastore
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
require 'erb'
require 'tempfile'

Puppet::Type.type(:onedatastore).provide(:onedatastore) do
  desc "onedatastore provider"

  has_command(:onedatastore, "onedatastore") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  def create
    file = Tempfile.new("onedatastore-#{resource[:name]}")
    template = ERB.new <<-EOF
NAME = <%= resource[:name] %>
TM_MAD = <%= resource[:tm] %>
TYPE = <%= resource[:type].upcase %>
<% if resource[:dm] %>
DS_MAD = <%= resource[:dm] %>
<% end %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onedatastore('create', file.path)
    @property_hash[:ensure] = :present
  end

  def destroy
    self.debug "Deleting datastore #{resource[:name]}"
    onedatastore('delete', resource[:name])
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.instances
    REXML::Document.new(onedatastore('list', '-x')).elements.collect("DATASTORE_POOL/DATASTORE") do |datastore|
      new(
        :name     => datastore.elements["NAME"].text,
        :ensure   => :present,
        :type     => datastore.elements["TEMPLATE/TYPE"].text,
        :dm       => (datastore.elements["TEMPLATE/DS_MAD"].text unless datastore.elements["TEMPLATE/DS_MAD"].nil?),
        :tm       =>( datastore.elements["TEMPLATE/TM_MAD"].text unless datastore.elements["TEMPLATE/TM_MAD"].nil?),
        :disktype => {0 => 'file', 1 => 'block', 2 => 'rdb'}[datastore.elements["DISK_TYPE"].text]
       )
    end
  end

  def self.prefetch(resources)
    datastores = instances
    resources.keys.each do |name|
      if provider = datastores.find{ |datastore| datastore.name == name }
        resources[name].provider = provider
      end
    end
  end

  #setters
  def type=(value)
      raise "Can not modify type. You need to delete and recreate the datastore"
  end

  def dm=(value)
      raise "Can not modify ds_mad. You need to delete and recreate the datastore"
  end

  def tm=(value)
      raise "Can not modify tm_mad. You need to delete and recreate the datastore"
  end

  def disktype=(value)
      raise "Can not mdoify disktype. You need to delete and recreate the datastore"
  end
end
