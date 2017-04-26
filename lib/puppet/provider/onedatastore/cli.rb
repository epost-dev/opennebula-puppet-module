# OpenNebula Puppet provider for onedatastore
#
# License: APLv2
#
# Authors:
# Based upon initial work from Ken Barber
# Modified by Martin Alfke
# Modified by Robert Waffen <robert.waffen@epost-dev.de>
# Modified by Arne Hilmann
# Modified by Gerald Schmidt
#
# Copyright
# initial provider had no copyright
# Deutsche Post E-POST Development GmbH - 2014, 2015
#

require 'rubygems'
require 'nokogiri' if Puppet.features.nokogiri?

Puppet::Type.type(:onedatastore).provide(:cli) do
  confine :feature => :nokogiri
  desc 'onedatastore provider'

  has_command(:onedatastore, 'onedatastore') do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  def self.get_attributes
    get_checked_attributes + [:safe_dirs, :driver, :bridge_list,
     :ceph_host, :ceph_user, :ceph_secret, :pool_name, :staging_dir, :base_path,
     :ensure, :cluster, :cluster_id]
  end

  def self.get_checked_attributes
    [:name, :ds_mad, :tm_mad, :disk_type, :type]
  end  

  def create
    file = Tempfile.new("onedatastore-#{resource[:name]}")
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.DATASTORE do
        self.class.get_attributes.each do |node|
          xml.send node.to_s.upcase, resource[node] unless resource[node].nil?

          if node.to_s == "cluster_id" and not resource[node].nil?
            self.warning "#{node} specified but datastore will not be added to the cluster; the only change is that the parameter is added to the onedatastore template; call `onecluster adddatastore` to add the datastore to the cluster"
          end
        end
      end
    end
    tempfile = builder.to_xml
    file.write(tempfile)
    file.close
    self.debug "Adding new datastore using: #{tempfile}"
    onedatastore('create', file.path)
    post_validate_change
    file.delete
    
    @property_hash[:ensure] = :present
  end

  def post_validate_change
    unless resource[:self_test]
      self.debug ":self_test not defined"
      return
    end

    self.debug ":self_test defined: running post validation"

    [1..3].each do
      if is_status_success?
        break
      end
      sleep 30 
    end

    unless is_status_success?
      Puppet.debug("#{__method__}: attempts_max exceeded")
      raise "Failed to apply resource: status not 'ready'"
    end

    unless is_obj_valid?
      raise "Failed to apply resources; object doesn't match parameters"
    end
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
    datastore_hash = Hash.new
    get_attributes.each do |node|
      if node == :base_path
        ## removes a char, one or more digits from the end
        #  required to match basepath /tmp vs /tmp/102
        text = xml.css("#{node.to_s.upcase}").first.text.sub!(/.\d+\z/, '')
        datastore_hash[node] = text
      elsif node == :type
        case xml.css("#{node.to_s.upcase}").first.text
          when '0' then text = 'IMAGE_DS'
          when '1' then text = 'SYSTEM_DS'
          when '2' then text = 'FILE_DS'
        end
        datastore_hash[node] = text
      elsif node == :disk_type
        case xml.css("#{node.to_s.upcase}").first.text
          when '0' then text = 'file'
          when '1' then text = 'block'
          when '3' then text = 'rbd'
        end
        datastore_hash[node] = text
      else
        datastore_hash[node] = xml.css("#{node.to_s.upcase}").first.text unless xml.css("#{node.to_s.upcase}").first.nil?
      end
    end
    datastore_hash
  end

  def is_status_success?
    # see https://github.com/OpenNebula/one/blob/master/include/Datastore.h
    # ll. 68ff.
    #
    # enum DatastoreState
    # {
    #     READY     = 0, /** < Datastore ready to use */
    #     DISABLED  = 1  /** < System Datastore can not be used */
    # };
    status_ready = 0
    datastore = Nokogiri::XML(onedatastore('show', resource[:name], '-x')).root.xpath('DATASTORE')
    (datastore.xpath('STATE').text.to_i == status_ready)
  end

  def is_obj_valid?
    datastore = self.class.get_datastore(Nokogiri::XML(onedatastore('show', resource[:name], '-x')).xpath('DATASTORE'))

    self.class.get_checked_attributes.each do |item|
      val = datastore[item]
      res_val = resource[item].to_s
      if val != res_val
        Puppet.debug("Value mismatch: '#{val}' != '#{res_val}' for item '#{item}'")
        return false
      end
    end
    true
  end

  def self.instances
    datastores = Nokogiri::XML(onedatastore('list', '-x')).xpath('/DATASTORE_POOL/DATASTORE')
    datastores.collect do |datastore|
      data_hash = get_datastore(datastore)
      data_hash[:ensure] = :present
      new(data_hash)
    end
  end

  def self.prefetch(resources)
    resources.keys.each do |name|
      provider = instances.find { |datastore| datastore.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  def flush
    file = Tempfile.new("onedatastore-#{resource[:name]}")

    tempfile = @property_hash.map { |k, v|
      unless resource[k].nil? or resource[k].to_s.empty? or [:name, :provider, :ensure].include?(k)
        [k.to_s.upcase, v]
      end
    }.map { |a| "#{a[0]} = \"#{a[1]}\"" unless a.nil? }.join("\n")

    file.write(tempfile)
    file.close
    Puppet.debug("Updating datastore using:\n#{tempfile}")
    onedatastore('update', resource[:name], file.path, '--append') unless @property_hash.empty?
    file.delete
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
