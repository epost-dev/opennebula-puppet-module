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
require 'pp'

Puppet::Type.type(:onedatastore).provide(:cli) do
  desc 'onedatastore provider'

  has_command(:onedatastore, 'onedatastore') do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  def create
    file = Tempfile.new("onedatastore-#{resource[:name]}")

    xml_nodes= [:name, :tm_mad, :type, :safe_dirs, :ds_mad, :disk_type, :driver, :bridge_list,
                :ceph_host, :ceph_user, :ceph_secret, :pool_name, :staging_dir, :base_path, :cluster]

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.DATASTORE do
        xml_nodes.each do |node|
          xml.send node.to_s.upcase, resource[node] unless resource[node].nil?
        end
      end
    end

    tempfile = builder.to_xml
    file.write(tempfile)
    file.close
    self.debug "Adding new network using datastore: #{tempfile}"
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

  def self.get_list_of_datastores
    xml_nodes= [:name, :tm_mad, :type, :safe_dirs, :ds_mad, :disk_type, :driver, :bridge_list,
                :ceph_host, :ceph_user, :ceph_secret, :pool_name, :staging_dir, :base_path, :cluster]

    datastore_hash = {}

    datastores = Nokogiri::XML(onedatastore('list', '-x')).xpath('/DATASTORE_POOL/DATASTORE').each do |datastore|
      xml_nodes.each do |node|
        datastore_hash[node] = datastore.css("#{node.to_s.upcase}").first.text unless datastore.css("#{node.to_s.upcase}").first.nil?
      end
    end
    pp datastore_hash
  end

  def self.instances
    datastores = Nokogiri::XML(onedatastore('list', '-x')).xpath('/DATASTORE_POOL/DATASTORE')

    datastores.collect do |datastore|
    get_list_of_datastores
      new(
          :ensure => :present,
          :name => datastore.css('NAME').first.text,
          :type => datastore.css('TYPE').first.text,
          :ds_mad => (datastore.css('DS_MAD').first.text unless datastore.xpath('./TEMPLATE/DS_MAD').nil?)
      )
      # :safe_dirs => (datastore.xpath('./TEMPLATE/SAFE_DIRS').text unless datastore.xpath('./TEMPLATE/SAFE_DIRS').nil?),
      # :tm_mad => (datastore.xpath('./TEMPLATE/TM_MAD').text unless datastore.xpath('./TEMPLATE/TM_MAD').nil?),
      # :base_path => (datastore.xpath('./TEMPLATE/BASE_PATH').text unless datastore.xpath('./TEMPLATE/BASE_PATH').nil?),
      # :bridge_list => (datastore.xpath('./TEMPLATE/BRIDGE_LIST').text unless datastore.xpath('./TEMPLATE/BRIDGE_LIST').nil?),
      # :ceph_host => (datastore.xpath('./TEMPLATE/CEPH_HOST').text unless datastore.xpath('./TEMPLATE/CEPH_HOST').nil?),
      # :ceph_user => (datastore.xpath('./TEMPLATE/CEPH_USER').text unless datastore.xpath('./TEMPLATE/CEPH_USER').nil?),
      # :ceph_secret => (datastore.xpath('./TEMPLATE/CEPH_SECRET').text unless datastore.xpath('./TEMPLATE/CEPH_SECRET').nil?),
      # :pool_name => (datastore.xpath('./TEMPLATE/POOL_NAME').text unless datastore.xpath('./TEMPLATE/POOL_NAME').nil?),
      # :staging_dir => (datastore.xpath('./TEMPLATE/STAGING_DIR').text unless datastore.xpath('./TEMPLATE/STAGING_DIR').nil?),
      # :driver => (datastore.xpath('./TEMPLATE/DRIVER').text unless datastore.xpath('./TEMPLATE/DRIVER').nil?),
      # :disk_type => {'0' => 'file', '1' => 'block', '3' => 'rbd'}[datastore.xpath('./DISK_TYPE').text]
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

  def dm=(value)
    raise 'Can not modify ds_mad. You need to delete and recreate the datastore'
  end

  def tm=(value)
    raise 'Can not modify tm_mad. You need to delete and recreate the datastore'
  end

  def disktype=(value)
    raise 'Can not modify disktype. You need to delete and recreate the datastore'
  end

  def basepath=(value)
    raise 'Can not modify basepath. You need to delete and recreate the datastore'
  end
end
