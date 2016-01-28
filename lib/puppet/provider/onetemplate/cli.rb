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

  # Create a VM template with onetemplate by passing in a temporary template definition file.
  def create
    file = Tempfile.new("onetemplate-#{resource[:name]}")
    builder = Nokogiri::XML::Builder.new do |xml|
        xml.TEMPLATE do
            xml.NAME resource[:name]
            xml.MEMORY resource[:memory]
            xml.CPU resource[:cpu]
            xml.VCPU resource[:vcpu]
            xml.DESCRIPTION do
                resource[:description]
            end if resource[:description]
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
        end
    end
    tempfile = builder.to_xml
    file.write(tempfile)
    file.close
    self.debug "Creating template using #{tempfile}"
    onetemplate('create', file.path)
    file.delete
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
            :disks       => template.xpath('./TEMPLATE/DISK').map { |disk| disk.xpath('./IMAGE').text },
            :features    => Hash[template.xpath('./TEMPLATE/FEATURES/*').map { |e| [e.name.downcase, { e.text => e.text, 'true' => true, 'false' => false }[e.text.downcase]] } ],
            :graphics    => Hash[template.xpath('./TEMPLATE/GRAPHICS/*').map { |e| [e.name.downcase, e.text.downcase] } ],
            :memory      => (template.xpath('./TEMPLATE/MEMORY').text unless template.xpath('./TEMPLATE/MEMORY').nil?),
            :nics        => template.xpath('./TEMPLATE/NIC').map { |nic| nic.xpath('./NETWORK').text },
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
    file = Tempfile.new('onevnet')
    file << @property_hash.map { |k, v|
      unless resource[k].nil? or resource[k].to_s.empty? or [:name, :provider, :ensure].include?(k)
        [ k.to_s.upcase, v ]
      end
    }.map{|a| "#{a[0]} = #{a[1]}" unless a.nil? }.join("\n")
    file.close
    self.debug(IO.read file.path)
    onetemplate('update', resource[:name], file.path, '--append') unless @property_hash.empty?
    file.delete
  end

end
