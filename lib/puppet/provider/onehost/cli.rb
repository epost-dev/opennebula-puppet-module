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

  has_command(:onehost, "onehost") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  def create
    onehost('create', resource[:name], '--im', resource[:im_mad], '--vm', resource[:vm_mad], '--net', resource[:vn_mad])
    @property_hash[:ensure] = :present
  end

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
      provider = hosts.find{ |host| host.name == name }
      resources[name].provider = provider unless provider.nil?
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
