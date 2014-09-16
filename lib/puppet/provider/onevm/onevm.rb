require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onevm).provide(:onevm) do
  desc "onevm provider"

  has_command(:onevm, "onevm") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end
  has_command(:onetemplate, "onetemplate") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  # Create a VM with onevm by passing in a temporary template.
  def create
      # create template content from template
      template_output = onetemplate('show', resource[:template])
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
      onevm('create', file.path)
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
    REXML::Document.new(onevm('list', '-x')).elements.collect("VM_POOL/VM") do |vm|
      new(
        :name     => vm.elements["NAME"].text,
        :ensure   => :present,
        :template => vm.elements["TEMPLATE/TEMPLATE_ID"]  # TODO get template name insted of ID
      )
    end
  end

  def self.prefetch(resources)
    vms = instances
    resources.keys.each do |name|
      if provider = vms.find{ |vm| vm.name == name }
        resources[name].provider = provider
      end
    end
  end

  # setters
  def template=(value)
      raise "Can not modify a VM template"
  end
end
