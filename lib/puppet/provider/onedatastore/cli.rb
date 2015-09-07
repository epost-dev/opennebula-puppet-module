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
# Deutsche Post E-POST Development GmbH - 2014, 2015
#

require 'rubygems'
require 'nokogiri'

Puppet::Type.type(:onedatastore).provide(:cli) do
  desc 'onedatastore provider'

  has_command(:onedatastore, 'onedatastore') do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  def self.get_attributes
    xml_nodes = [:name, :tm_mad, :type, :safe_dirs, :ds_mad, :disk_type, :driver, :bridge_list,
                 :ceph_host, :ceph_user, :ceph_secret, :pool_name, :staging_dir, :base_path, :ensure, :cluster]
  end

  def create
    file = Tempfile.new("onedatastore-#{resource[:name]}")

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.DATASTORE do
        self.class.get_attributes.each do |node|
          xml.send node.to_s.upcase, resource[node] unless resource[node].nil?
        end
      end
    end

    tempfile = builder.to_xml
    file.write(tempfile)
    file.close
    self.debug "Adding new datastore using: #{tempfile}"
    onedatastore('create', file.path)
    file.delete
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

  def self.get_datastore(xml)
    datastore_hash = {}
    get_attributes.each do |node|
      if node == :type
        case xml.css("#{node.to_s.upcase}").first.text
          when '0' then text = 'IMAGE_DS'
          when '1' then text = 'SYSTEM_DS'
          when '2' then text = 'FILE_DS'
        end
        datastore_hash[node] = text
        next
      end

      if node == :disk_type
        case xml.css("#{node.to_s.upcase}").first.text
          when '0' then text = 'file'
          when '1' then text = 'block'
          when '3' then text = 'rbd'
        end
        datastore_hash[node] = text
        next
      end
      datastore_hash[node] = xml.css("#{node.to_s.upcase}").first.text unless xml.css("#{node.to_s.upcase}").first.nil?
    end
    datastore_hash
  end

  def self.instances
    datastores = Nokogiri::XML(onedatastore('list', '-x')).xpath('/DATASTORE_POOL/DATASTORE')
    datastores.collect do |datastore|
      data_hash = get_datastore datastore
      data_hash[:ensure] = :present
      new(data_hash)
    end
  end

  def self.prefetch(resources)
    datastores = instances
    resources.keys.each do |name|
      provider = datastores.find { |datastore| datastore.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  #setters
  def type=(value)
    raise 'Can not modify type. You need to delete and recreate the datastore'
  end

  def ds_mad=(value)
    raise 'Can not modify ds_mad. You need to delete and recreate the datastore'
  end

  def tm_mad=(value)
    raise 'Can not modify tm_mad. You need to delete and recreate the datastore'
  end

  def disk_type=(value)
    raise 'Can not modify disktype. You need to delete and recreate the datastore'
  end

  def base_path=(value)
    raise 'Can not modify basepath. You need to delete and recreate the datastore'
  end
end
