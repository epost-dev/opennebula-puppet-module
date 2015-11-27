# OpenNebula Puppet provider for onehost
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

Puppet::Type.type(:onehost).provide(:cli) do
  desc "onehost provider"

  commands(:onehost => "onehost") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  def create
    onehost('create', resource[:name], '--im', resource[:im_mad], '--vm', resource[:vm_mad], '--net', resource[:vn_mad])
    Puppet.debug("Validate Resource State")
    post_validate_change
    @property_hash[:ensure] = :present
  end

  #TODO: requires validation as well
  def destroy
    onehost('delete', resource[:name])
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.instances
     hosts = Nokogiri::XML(onehost('list','-x')).root.xpath('/HOST_POOL/HOST')
     hosts.collect do |host|
        new(
           :name   => host.xpath('./NAME').text,
           :ensure => :present,
           :im_mad => host.xpath('./IM_MAD').text,
           :vm_mad => host.xpath('./VM_MAD').text,
           :vn_mad => host.xpath('./VN_MAD').text
        )
	 end
  end

  def self.prefetch(resources)
    hosts = instances
    resources.keys.each do |name|
      if provider = hosts.find{ |host| host.name == name }
        resources[name].provider = provider
      end
    end
  end

  def postfetch()
    # In difference to self.instances validation requires the state since, this is necessary to
    # judge weather a host was created successfully or not
    host = Nokogiri::XML(onehost('show', resource[:name], '-x')).root.xpath('/HOST')
    @post_property_hash = Hash.new
    @post_property_hash[:name] = host.xpath('./NAME').text.to_s
    @post_property_hash[:im_mad] = host.xpath('./IM_MAD').text.to_s
    @post_property_hash[:vm_mad] = host.xpath('./VM_MAD').text.to_s
    @post_property_hash[:vn_mad] = host.xpath('./VN_MAD').text.to_s
    @post_property_hash[:status] = {'0' => 'init', '1' => 'update', '2' => 'enabled','3' => 'error', '4' => 'disabled', '5' => 'enabled', '6' => 'enabled', '7' => 'enabled'}[host.xpath('./STATE').text]
  end

  def post_validate_change()
    unless resource[:self_test]
      Puppet.debug("nothing to validate, bye bye")
      return
    end
    Puppet.debug("Validating state")
    postfetch
    resource_state = Hash.new
    resource_state[:name] = resource[:name].to_s
    resource_state[:im_mad] = resource[:im_mad].to_s
    resource_state[:vm_mad] = resource[:vm_mad].to_s
    resource_state[:vn_mad] = resource[:vn_mad].to_s
    resource_state[:status] = 'enabled' # <- Hardcoded since enabled is the only reasonable state

    max_attempts = 3
    attempts = 0
    sleep_time = 30

    while @post_property_hash != resource_state do
        attempts += 1
        sleep sleep_time
        postfetch
        if @post_property_hash[:status].to_s == 'error' and resource_state[:status].to_s != 'error'
          raise "Failed to apply resource, final Resource state: #{@post_property_hash[:status]}"
        end
        if attempts == max_attempts and @post_property_hash != resource_state
          raise "Failed to apply resource change"
        end
    end

  end

  # setters
  def im_mad=(value)
     raise "onehosts can not be updated. You have to remove and recreate the host"
  end

  def vm_mad=(value)
     raise "onehosts can not be updated. You have to remove and recreate the host"
  end

  def vn_mad=(value)
     raise "onehosts can not be updated. You have to remove and recreate the host"
  end

end
