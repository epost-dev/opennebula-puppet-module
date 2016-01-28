# OpenNebula Puppet provider for onevm
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
require 'nokogiri' if Puppet.features.nokogiri?
require 'tempfile'
require 'erb'

Puppet::Type.type(:onevm).provide(:cli) do
  confine :feature => :nokogiri
  desc "onevm provider"

  has_command(:onevm, "onevm") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end
  has_command(:onetemplate, "onetemplate") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  # Create a VM with onetemplate instantiate.
  def create
    onetemplate('instantiate', resource[:template], '--name', resource[:name])
    @property_hash[:ensure] = :present
  end

  # Destroy a VM using onevm delete
  def destroy
    onevm('delete', resource[:name])
    @property_hash.clear
  end

  # Check if a VM exists by scanning the onevm list
  def exists?
    @property_hash[:ensure] == :present
  end

  # Return the full hash of all existing onevm resources
  def self.instances
    vms = Nokogiri::XML(onevm('list','-x')).root.xpath('/VM_POOL/VM')
    vms.collect do |vm|
        template_id = vm.xpath('./TEMPLATE/TEMPLATE_ID').text
        template_name = Nokogiri::XML(onetemplate('show',template_id,'-x')).root.xpath('/VMTEMPLATE/NAME').text
        new(
            :name        => vm.xpath('./NAME').text,
            :ensure      => :present,
            :template    => template_name,
            :description => vm.xpath('./TEMPLATE/DESCRIPTION').text
        )
    end
  end

  def self.prefetch(resources)
    vms = instances
    resources.keys.each do |name|
      provider = vms.find{ |vm| vm.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  # setters
  def template=(value)
      raise 'Can not modify a VM template'
  end
end
