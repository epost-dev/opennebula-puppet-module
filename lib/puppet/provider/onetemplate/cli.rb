# OpenNebula Puppet provider for onetemplate
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

Puppet::Type.type(:onetemplate).provide(:cli) do
  confine :feature => :nokogiri
  desc "onetemplate provider"

  has_command(:onetemplate, "onetemplate") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  # build the xml needed to update a template
  def build_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.TEMPLATE do
        xml.NAME resource[:name]
        xml.MEMORY resource[:memory]
        xml.CPU resource[:cpu]
        xml.VCPU resource[:vcpu]
        xml.DESCRIPTION resource[:description] if resource[:description]
        xml.OS do
          resource[:os].each do |k, v|
            xml.send(k.upcase, v)
          end
        end if resource[:os]
        resource[:disks].each do |disk|
          xml.DISK do
            disk.each do |k, v|
              xml.send(k.upcase, v)
            end
          end
        end if resource[:disks]
        resource[:nics].each do |nic|
          xml.NIC do
            nic.each do |k, v|
              xml.send(k.upcase, v)
            end
          end
        end if resource[:nics]
        xml.GRAPHICS do
          resource[:graphics].each do |k, v|
            xml.send(k.upcase, v)
          end
        end if resource[:graphics]
        xml.FEATURES do
          resource[:features].each do |k, v|
            xml.send(k.upcase, v)
          end
        end if resource[:features]
        xml.CONTEXT do
          resource[:context].each do |k, v|
            xml.send(k.upcase, v)
          end
        end if resource[:context]
        xml.SCHED_REQUIREMENTS resource[:sched_requirements] if resource[:sched_requirements]
        xml.SCHED_RANK resource[:sched_rank] if resource[:sched_rank]
        xml.SCHED_DS_REQUIREMENTS resource[:sched_ds_requirements] if resource[:sched_ds_requirements]
        xml.SCHED_DS_RANK resource[:sched_ds_rank] if resource[:sched_ds_rank]
      end
    end
    builder.to_xml
  end

  # Create a VM template with onetemplate by passing in a temporary template definition file.
  def create
    xml_content = build_xml

    Tempfile.create("onetemplate-#{resource[:name]}") {|fp|
      self.debug "Creating template using #{xml_content}"
      fp.write(xml_content)
      onetemplate('create', fp.path)
    }
    @property_hash[:ensure] = :present
  end

  # Destroy a VM using onevm delete
  def destroy
    onetemplate('delete', resource[:name])
    @property_hash.clear
  end

  # Check if a VM exists by scanning the onevm list
  def exists?
    @property_hash[:ensure] == :present
  end

  # Return the full hash of all existing onevm resources
  def self.instances
    templates = Nokogiri::XML(onetemplate('list', '-x')).root.xpath('/VMTEMPLATE_POOL/VMTEMPLATE')
    templates.collect do |template|
      new(
        :name        => template.xpath('./NAME').text,
        :ensure      => :present,
        :description => template.xpath('./TEMPLATE/DESCRIPTION').text,
        :context     => Hash[template.xpath('./TEMPLATE/CONTEXT/*').map { |e| [e.name.downcase, e.text.downcase] } ],
        :cpu         => (template.xpath('./TEMPLATE/CPU').text unless template.xpath('./TEMPLATE/CPU').nil?),
        :disks       => Hash[template.xpath('./TEMPLATE/DISK/*').map { |e| [e.name.downcase, e.text.downcase] } ],
        :features    => Hash[template.xpath('./TEMPLATE/FEATURES/*').map { |e| [e.name.downcase, { e.text => e.text, 'true' => true, 'false' => false }[e.text.downcase]] } ],
        :graphics    => Hash[template.xpath('./TEMPLATE/GRAPHICS/*').map { |e| [e.name.downcase, e.text.downcase] } ],
        :memory      => (template.xpath('./TEMPLATE/MEMORY').text unless template.xpath('./TEMPLATE/MEMORY').nil?),
        :nics        => Hash[template.xpath('./TEMPLATE/NIC/*').map { |e| [e.name.downcase, e.text.downcase] } ],
        :os          => Hash[template.xpath('./TEMPLATE/OS/*').map { |e| [e.name.downcase, e.text.downcase] } ],
        :vcpu        => (template.xpath('./TEMPLATE/VCPU').text unless template.xpath('./TEMPLATE/VCPU').nil?)
      )
    end
  end

  def self.prefetch(resources)
    templates = instances
    resources.keys.each do |name|
      provider = templates.find { |template| template.name == name }
      resources[name].provider = provider unless provider.nil?
    end
  end

  def flush
    xml_content = build_xml

    Tempfile.create("onetemplate-#{resource[:name]}") {|fp|
      self.debug "Creating template using #{xml_content}"
      fp.write(xml_content)
      onetemplate('update', resource[:name], fp.path, '--append') unless @property_hash.empty?
    }
  end

end
