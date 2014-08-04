require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:oneimage).provide(:oneimage) do
  desc "oneimage provider"

  commands :oneimage => "oneimage"

  # Create a network with onevnet by passing in a temporary template.
  def create
    file = Tempfile.new("oneimage-#{resource[:name]}")
    File.chmod(0644, file.path)

    template = ERB.new <<-EOF
NAME = "<%= resource[:name] %>"
<% if resource[:description] %>DESCRIPTION = "<%= resource[:description] %>"<% end%>
<% if resource[:type] %>TYPE = <%= resource[:type].upcase %><% end%>
<% if resource[:public] %>PUBLIC = <%= resource[:public] ? "YES" : "NO" %><% end%>
<% if resource[:persistent] %>PERSISTENT = <%= resource[:persistent] ? "YES" : "NO" %><% end%>
<% if resource[:dev_prefix] %>DEV_PREFIX = "<%= resource[:dev_prefix] %>"<% end%>
<% if resource[:bus] %>BUS = "<%= resource[:bus] %>"<% end%>
<% if resource[:path] %>PATH = <%= resource[:path] %><% end%>
<% if resource[:source] %>SOURCE = <%= resource[:source] %><% end%>
<% if resource[:fstype] %>FSTYPE = <%= resource[:fstype] %><% end%>
<% if resource[:size] %>SIZE = <%= resource[:size] %><% end%>
EOF

    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "oneimage register #{file.path} ", self.class.login
    `#{output}`
  end

  # Destroy a network using onevnet delete
  def destroy
    output = "oneimage delete #{resource[:name]} ", self.class.login
    `#{output}`
  end

  # Return a list of existing networks using the onevnet -x list command
  def self.oneimage_list
    xml = REXML::Document.new(`oneimage -x list`)
    oneimages = []
    xml.elements.each("IMAGE_POOL/IMAGE/NAME") do |element|
      oneimages << element.text
    end
    oneimages
  end

  # Check if a network exists by scanning the onevnet list
  def exists?
    self.class.oneimage_list().include?(resource[:name])
  end

  # Return the full hash of all existing onevnet resources
  def self.instances
    instances = []
    oneimage_list.each do |image|
      hash = {}

      # Obvious resource attributes
      hash[:provider] = self.name.to_s
      hash[:name] = image

      # Open onevnet xml output using REXML
      xml = REXML::Document.new(`oneimage -x show #{image}`)

      # Traverse the XML document and populate the common attributes
      xml.elements.each("IMAGE/TEMPLATE/DESCRIPTION") { |element|
        hash[:description] = element.text
      }
      xml.elements.each("IMAGE/TEMPLATE/TYPE") { |element|
        hash[:type] = element.text.downcase
      }
      xml.elements.each("IMAGE/PUBLIC") { |element|
        hash[:public] = element.text == "1" ? true : false
      }
      xml.elements.each("IMAGE/PERSISTENT") { |element|
        hash[:persistent] = element.text == "1" ? true : false
      }
      xml.elements.each("IMAGE/TEMPLATE/DEV_PREFIX") { |element|
        hash[:dev_prefix] = element.text
      }
      xml.elements.each("IMAGE/TEMPLATE/BUS") { |element|
        hash[:bus] = element.text.downcase
      }
      xml.elements.each("IMAGE/TEMPLATE/PATH") { |element|
        hash[:path] = element.text
      }
      xml.elements.each("IMAGE/TEMPLATE/SOURCE") { |element|
        hash[:source] = element.text
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
end
