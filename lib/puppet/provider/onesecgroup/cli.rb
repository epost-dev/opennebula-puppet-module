# Opennebula onesecgroup provider for Security Groups
#
# License: APLv2
#
# Authors:
# Based upon initial work from Ken Barber
# Modified by John Noss, Harvard University FAS Research Computing, 2015
#
# Copyright
# initial provider had no copyright
# Deutsche Post E-POST Development GmbH - 2014, 2015
#

require 'rubygems'
require 'nokogiri' if Puppet.features.nokogiri?

Puppet::Type.type(:onesecgroup).provide(:cli) do
  confine :feature => :nokogiri
  desc "onesecgroup provider"

  has_command(:onesecgroup, "onesecgroup") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  # Create a security group with onesecgroup by passing in a temporary secgroup definition file.
  def create
    file = Tempfile.new("onesecgroup-#{resource[:name]}-create.xml")
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.TEMPLATE do
        xml.NAME resource[:name]
        xml.DESCRIPTION resource[:description]
        resource[:rules].each do |rule|
          xml.RULE do
            rule.each do |k, v|
              xml.send(k.upcase, v)
            end
          end
        end if resource[:rules]
      end
    end
    tempfile = builder.to_xml
    file.write(tempfile)
    file.close
    self.debug "Creating secgroup using #{tempfile}"
    onesecgroup('create', file.path)
    file.delete
    @property_hash[:ensure] = :present
  end

  # Delete a secgroup using onesecgroup delete
  def destroy
    onesecgroup('delete', resource[:name])
    @property_hash.clear
  end

  # Check if a secgroup exists by scanning the onesecgroup list
  def exists?
    @property_hash[:ensure] == :present
  end

  # Return the full hash of all existing secgroups
  def self.instances
    secgroups = Nokogiri::XML(onesecgroup('list', '-x')).root.xpath('/SECURITY_GROUP_POOL/SECURITY_GROUP')
    secgroups.collect do |secgroup|
      rules=[]
      secgroup.xpath('./TEMPLATE/RULE').collect do |rule|
        ruleitems={}
        rule.xpath('*').collect do |item|
          ruleitems[item.name.downcase] = item.text.upcase
        end
        rules << ruleitems
      end
      new(
        :name        => secgroup.xpath('./NAME').text,
        :ensure      => :present,
        :description => secgroup.xpath('./TEMPLATE/DESCRIPTION').text,
        :rules       => rules
      )
    end
  end

  def self.prefetch(resources)
    secgroups = instances
    resources.keys.each do |name|
      provider = secgroups.find{ |secgroup| secgroup.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  # Write out changes to a security group with onesecgroup update
  def flush
    file = Tempfile.new("onesecgroup-#{resource[:name]}-update.xml")
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.TEMPLATE do
        xml.DESCRIPTION resource[:description]
        resource[:rules].each do |rule|
          xml.RULE do
            rule.each do |k, v|
              xml.send(k.upcase, v)
            end
          end
        end if resource[:rules]
      end
    end
    tempfile = builder.to_xml
    file.write(tempfile)
    file.close
    self.debug "Updating secgroup using #{tempfile}"
    onesecgroup('update', resource[:name], file.path) unless @property_hash.empty?
    file.delete
  end

end