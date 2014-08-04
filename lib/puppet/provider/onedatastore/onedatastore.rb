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
# Deutsche Post E-POST Development GmbH - 2014
#

require 'rexml/document'
require 'erb'
require 'tempfile'

Puppet::Type.type(:onedatastore).provide(:onedatastore) do
  desc "onedatastore provider"

  commands :onedatastore => "onedatastore"

  def create
    file = Tempfile.new("onedatastore-#{resource[:name]}")
    template = ERB.new <<-EOF
NAME = <%= resource[:name] %>
TM_MAD = <%= resource[:tm] %>
TYPE = <%= resource[:type].upcase %>
<% if resource[:dm] %>
DS_MAD = <%= resource[:dm] %>
<% end %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onedatastore create #{file.path} ", self.class.login
    `#{output}`
  end

  def destroy
      output = "onedatastore delete #{resource[:name]} ", self.class.login()
      self.debug "Running command #{output}"
      `#{output}`
  end

  def exists?
    if self.class.onedatastore_list().include?(resource[:name])
        self.debug "Found datastore #{resource[:name]}"
        true
    end
  end

  def self.onedatastore_list
    xml = REXML::Document.new(`onedatastore list -x`)
    list = []
    xml.elements.each("DATASTORE_POOL/DATASTORE/NAME") do |datastore|
      list << datastore.text
    end
    list
  end

  def self.instances
    instances = []

    onedatastore_list().each do |datastore|
      self.debug "getting properties for ds: #{datastore}"
      hash = {}
      hash[:provider] = self.class.name.to_s
      hash[:name] = datastore
      output = "onedatastore show --xml #{datastore} ", login
      self.debug "Running command #{output}"
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("DATASTORE/TEMPLATE/TM_MAD") { |element|
          hash[:tm] = element.text
      }
      xml.elements.each("DATASTORE/TEMPLATE/DS_MAD") { |element|
          hash[:dm] = element.text
      }
      xml.elements.each("DATASTORE/TEMPLATE/TYPE") { |element|
          hash[:type] = element.text
      }
      xml.elements.each("DATASTORE/DISK_TYPE") { |element|
          case element.text
          when '0'
              hash[:disktype] = 'file'
          when '1'
              hash[:disktype] = 'block'
          when '2'
              hash[:disktype] = 'rdb'
          end
      }
      instances << new(hash)
    end

    instances
  end

  # login credentials
  def self.login
    credentials = File.read('/var/lib/one/.one/one_auth').strip.split(':')
    user = credentials[0]
    password = credentials[1]
    login = " --user #{user} --password #{password}"
    login
  end

  #getters
  def disktype
      result = ''
      output = "onedatastore show --xml #{resource[:name]} ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("DATASTORE/DISK_TYPE") { |element|
          case element.text
          when '0'
              result = 'file'
          when '1'
              result = 'block'
          when '2'
              result = 'rdb'
          end
      }
      result
  end

  def dm
      result = ''
      output = "onedatastore show --xml #{resource[:name]} ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("DATASTORE/TEMPLATE/DS_MAD") { |element|
          result = element.text
      }
      result
  end

  def tm
      result = ''
      output = "onedatastore show --xml #{resource[:name]} ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("DATASTORE/TEMPLATE/TM_MAD") { |element|
          result = element.text
      }
      result
  end

  def type
      result = ''
      output = "onedatastore show --xml #{resource[:name]} ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("DATASTORE/TEMPLATE/TYPE") { |element|
          result = element.text
      }
      result
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
      raise "Can not mdoify disktype. You need to delete and recreate the datastore"
  end
end
