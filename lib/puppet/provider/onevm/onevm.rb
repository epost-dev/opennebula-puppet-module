require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onevm).provide(:onevm) do
  desc "onevm provider"

  commands :onevm => "onevm"
  commands :onetemplate => "onetemplate"

  # Create a VM with onevm by passing in a temporary template.
  def create
      output = "onetemplate instantiate #{resource[:template]} #{resource[:name]}"
      `#{output}`
  end

  # Destroy a VM using onevm delete
  def destroy
    onevm "delete", resource[:name]
  end

  # Return a list of existing VM's using the onevm -x list command
  def self.onevm_list
    output = "onevm list --xml ", login
    xml = REXML::Document.new(`#{output}`)
    onevm = []
    xml.elements.each("VM_POOL/VM/NAME") do |element|
      onevm << element.text
    end
    onevm
  end

  # Check if a VM exists by scanning the onevm list
  def exists?
    if self.class.onevm_list().include?(resource[:name])
        self.debug "Found VM: #{resource[:name]}"
        true
    end
  end

  # Return the full hash of all existing onevm resources
  def self.instances
    instances = []
    onevm_list.each do |vm|
      hash = {}

      # Obvious resource attributes
      hash[:provider] = self.name.to_s
      hash[:name] = vm

      # Open onevm xml output using REXML
      output = "onevm show #{vm} --xml ", login
      xml = REXML::Document.new(`#{output}`)

      # Traverse the XML document and populate the common attributes
      xml.elements.each("VM/TEMPLATE/TEMPLATE_ID") { |element|
          template_output = "onetemplate show #{element} --xml ", login
          template_xml = REXML::Document.new(`#{template_output}`)
          template_xml.elements.each("VMTEMPLATE/NAME") { |template_element|
            hash[:template] = template_element.text
          }
      }

      instances << new(hash)
    end

    instances
  end

  def self.login
    credentials = File.read('/var/lib/one/.one/one_auth').strip.split(':')
    user = credentials[0]
    password = credentials[1]
    login = " --user #{user} --password #{password}"
    login
  end

  # getters
  def template
      result = ''
      output = "onevm show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("VM/TEMPLATE/TEMPLATE_ID") { |element|
          template_output = "onetemplate show #{element} --xml ", self.class.login
          template_xml = REXML::Document.new(`#{template_output}`)
          template_xml.elements.each("VMTEMPLATE/NAME") { |template_element|
            result = template_element.text
          }
      }
      result
  end
  # setters
  def template=(value)
      raise "Can not modify a VM template"
  end
end
