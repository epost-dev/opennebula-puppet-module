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
  desc "onedatastore provider"

  has_command(:onedatastore, "onedatastore") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  def create
    file = Tempfile.new("onedatastore-#{resource[:name]}")
    builder = Nokogiri::XML::Builder.new do |xml|
        xml.DATASTORE do
            xml.NAME resource[:name]
            xml.TM_MAD resource[:tm]
            xml.TYPE resource[:type].to_s.upcase
            xml.SAFE_DIRS do
                xml.send(resource[:safe_dirs].join(' '))
            end if resource[:safe_dirs]
            xml.DS_MAD resource[:dm]
            xml.DISK_TYPE resource[:disktype]
            xml.DRIVER resource[:driver]
            xml.BRIDGE_LIST resource[:bridgelist]
            xml.CEPH_HOST resource[:cephhost]
            xml.CEPH_USER resource[:cephuser]
            xml.CEPH_SECRET resource[:cephsecret]
            xml.POOL_NAME resource[:poolname]
            xml.STAGING_DIR resource[:stagingdir]
            xml.BASE_PATH do
                resource[:basepath]
            end if resource[:basepath]
        end
    end
    tempfile = builder.to_xml
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
      datastores = Nokogiri::XML(onedatastore('list','-x')).root.xpath('/DATASTORE_POOL/DATASTORE').map
      datastores.collect do |datastore|
        new(
            :name       => datastore.xpath('./NAME').text,
            :ensure     => :present,
            :type       => datastore.xpath('./TEMPLATE/TYPE').text,
            :dm         => (datastore.xpath('./TEMPLATE/DS_MAD').text unless datastore.xpath('./TEMPLATE/DS_MAD').nil?),
            :safe_dirs  => (datastore.xpath('./TEMPLATE/SAFE_DIRS').text unless datastore.xpath('./TEMPLATE/SAFE_DIRS').nil?),
            :tm         => (datastore.xpath('./TEMPLATE/TM_MAD').text unless datastore.xpath('./TEMPLATE/TM_MAD').nil?),
            :basepath   => (datastore.xpath('./TEMPLATE/BASE_PATH').text unless datastore.xpath('./TEMPLATE/BASE_PATH').nil?),
            :bridgelist => (datastore.xpath('./TEMPLATE/BRIDGE_LIST').text unless datastore.xpath('./TEMPLATE/BRIDGE_LIST').nil?),
            :cephhost   => (datastore.xpath('./TEMPLATE/CEPH_HOST').text unless datastore.xpath('./TEMPLATE/CEPH_HOST').nil?),
            :cephuser   => (datastore.xpath('./TEMPLATE/CEPH_USER').text unless datastore.xpath('./TEMPLATE/CEPH_USER').nil?),
            :cephsecret => (datastore.xpath('./TEMPLATE/CEPH_SECRET').text unless datastore.xpath('./TEMPLATE/CEPH_SECRET').nil?),
            :poolname   => (datastore.xpath('./TEMPLATE/POOL_NAME').text unless datastore.xpath('./TEMPLATE/POOL_NAME').nil?),
            :stagingdir => (datastore.xpath('./TEMPLATE/STAGING_DIR').text unless datastore.xpath('./TEMPLATE/STAGING_DIR').nil?),
            :driver     => (datastore.xpath('./TEMPLATE/DRIVER').text unless datastore.xpath('./TEMPLATE/DRIVER').nil?),
            :disktype   => {'0' => 'file', '1' => 'block', '3' => 'rbd'}[datastore.xpath('./DISK_TYPE').text]
        )
      end
  end

  def self.prefetch(resources)
    datastores = instances
    resources.keys.each do |name|
      provider = datastores.find{ |datastore| datastore.name == name }
      resources[name].provider = provider unless provider.nil?
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
      raise "Can not modify disktype. You need to delete and recreate the datastore"
  end

  def basepath=(value)
      raise "Can not modify basepath. You need to delete and recreate the datastore"
  end
end
