require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onevm).provide(:onevm) do
  desc "onevm provider"

  commands :onevm => "onevm"
  commands :onetemplate => "onetemplate"

  # Create a VM with onevm by passing in a temporary template.
  def create
      # create template content from template
      template_output = "onetemplate show #{resource[:template]}", self.class.login
      template_content = `#{template_output} | grep -A 100000 'TEMPLATE CONTENT' | grep -v 'TEMPLATE CONTENT'`
      file = Tempfile.new("onevm-#{resource[:name]}")
      template = ERB.new <<-EOF
NAME = <%= resource[:name] %>
<%= template_content %>
EOF
      
      tempfile = template.result(binding)
      file.write(tempfile)
      file.close
      self.debug "Creating onevm with template content: #{tempfile}"
      output = "onevm create #{file.path}", self.class.login
      self.debug "Running command #{output}"
      `#{output}`
  end

  # Destroy a VM using onevm delete
  def destroy
    output = "onevm delete #{resource[:name]} ", self.class.login
    `#{output}`
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
    output = "onevm list -x ", login
    REXML::Document.new(`#{output}`).elements.collect("VM_POOL/VM") do |vm|
      new(
        :name     => vm.elements["NAME"].text,
        :ensure   => :present,
        :template => vm.elements["TEMPLATE/TEMPLATE_ID"]  # TODO get template name insted of ID
      )
    end

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
