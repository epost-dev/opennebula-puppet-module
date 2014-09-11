require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:oneimage).provide(:oneimage) do
  desc "oneimage provider"

  commands :oneimage => "oneimage"

  mk_resource_methods

  # Create a network with onevnet by passing in a temporary template.
  def create
    file = Tempfile.new("oneimage-#{resource[:name]}")
    File.chmod(0644, file.path)

    template = ERB.new <<-EOF
NAME = "<%= resource[:name] %>"
<% if resource[:description] %>DESCRIPTION = "<%= resource[:description] %>"<% end%>
<% if resource[:type]        %>TYPE = <%=         resource[:type].upcase %><% end%>
<% if resource[:persistent]  %>PERSISTENT = <%=   resource[:persistent]  %><% end%>
<% if resource[:dev_prefix]  %>DEV_PREFIX = "<%=  resource[:dev_prefix]  %>"<% end%>
<% if resource[:driver]      %>DRIVER = "<%=      resource[:driver]      %>"<% end %>
<% if resource[:path]        %>PATH = <%=         resource[:path]        %><% end%>
<% if resource[:source]      %>SOURCE = <%=       resource[:source]      %><% end%>
<% if resource[:fstype]      %>FSTYPE = <%=       resource[:fstype]      %><% end%>
<% if resource[:size]        %>SIZE = <%=         resource[:size]        %><% end%>
EOF

    tempfile = template.result(binding)
    self.debug "Creating image using tempfile: #{tempfile}"
    file.write(tempfile)
    file.close
    output = "oneimage create -d #{resource[:datastore]} #{file.path} ", self.class.login
    `#{output}`
  end

  # Destroy a network using onevnet delete
  def destroy
    output = "oneimage delete #{resource[:name]} ", self.class.login
    `#{output}`
  end

  # Return a list of existing networks using the onevnet -x list command
  def self.oneimage_list
    output = "oneimage list --xml ", login
    xml = REXML::Document.new(`#{output}`)
    oneimages = []
    xml.elements.each("IMAGE_POOL/IMAGE/NAME") do |element|
      oneimages << element.text
    end
    oneimages
  end

  # Check if a network exists by scanning the onevnet list
  def exists?
    if self.class.oneimage_list().include?(resource[:name])
        self.debug "Found image #{resource[:name]}"
        true
    end
  end

  # Return the full hash of all existing oneimage resources
  def self.instances
    output = "oneimage list -x ", login
    REXML::Document.new(`#{output}`).elements.collect("IMAGE_POOL/IMAGE") do |image|
      elements = image.elements
      new(
        :name        => elements["NAME"].text,
        :ensure      => :present,
        :datastore   => elements["DATASTORE"].text,
        :description => elements["TEMPLATE/DESCRIPTION"].text,
        :dev_prefix  => elements["TEMPLATE/DEV_PREFIX"].text,
        :disk_type   => elements["DISK_TYPE"].text,
        :driver      => elements["DRIVER"].text,
        :fstype      => elements["FSTYPE"].text,
        :path        => (elements["TEMPLATE/PATH"] || elements["PATH"]).text,
        :persistent  => (elements["TEMPLATE/PERSISTENT"] || elements["PERSISTENT"]).text == "1",
        :size        => elements["SIZE"].text,
        :source      => (elements["TEMPLATE/SOURCE"] || elements["SOURCE"]).text,
        :target      => elements["TARGET"].text,
        :type        => ('context' if (elements["TEMPLATE/TYPE"] || elements["TYPE"]).text == '5')
      )
    end

  end

  # login credentials
  def self.login
    credentials = File.read('/var/lib/one/.one/one_auth').strip.split(':')
    user = credentials[0]
    password = credentials[1]
    login = " --user #{user} --password #{password}"
    login
  end

  # getters
  def datastore
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      # Traverse the XML document and populate the common attributes
      xml.elements.each("IMAGE/DATASTORE") { |element|
        result = element.text
      }
      result
  end
  def description
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/TEMPLATE/DESCRIPTION") { |element|
       result = element.text
      }
      result
  end
  def type
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/TYPE") { |element|
        case element.text
        when '5'
            result = 'context'
        end
      }
      xml.elements.each("IMAGE/TEMPLATE/TYPE") { |element|
        case element.text
        when '5'
            result = 'context'
        end
      }
      result
  end
  def persistent
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/PERSISTENT") { |element|
        result = element.text == "1" ? true : false
      }
      xml.elements.each("IMAGE/TEMPLATE/PERSISTENT") { |element|
        result = element.text == "1" ? true : false
      }
      result
  end
  def dev_prefix
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/TEMPLATE/DEV_PREFIX") { |element|
        result = element.text
      }
      result
  end
  def target
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/TARGET") { |element|
        result = element.text
      }
      result
  end
  def path
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/PATH") { |element|
        result = element.text
      }
      xml.elements.each("IMAGE/TEMPLATE/PATH") { |element|
        result = element.text
      }
      result
  end
  def driver
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/DRIVER") { |element|
        result = element.text
      }
      result
  end
  def disk_type
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/DISK_TYPE") { |element|
        result = element.text
      }
      result
  end
  def source
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/SOURCE") { |element|
        result = element.text
      }
      xml.elements.each("IMAGE/TEMPLATE/SOURCE") { |element|
        result = element.text
      }
      result
  end
  def size
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/SIZE") { |element|
        result = element.text
      }
      result
  end
  def fstype
      result = ''
      output = "oneimage show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("IMAGE/FSTYPE") { |element|
        result = element.text
      }
      result
  end

  #setters
  def datastore=(value)
      raise "Can not modify datastore on images"
  end
  def description=(value)
      raise "Can not modify description on images"
  end
  def type=(value)
      raise "Can not modify type of images"
  end
  def persistent=(value)
      raise "Can not make images persistent"
  end
  def dev_prefix=(value)
      raise "Can not modify dev_prefix on images"
  end
  def target=(value)
      raise "Can not modify target of images"
  end
  def path=(value)
      raise "Can not modify path of images"
  end
  def driver=(value)
      raise "Can not modify driver of images"
  end
  def disk_type=(value)
      raise "Can not modify disk_type of images"
  end
  def source=(value)
      raise "Can not modify source of images"
  end
  def size=(value)
      raise "Can not modify size of images"
  end
  def fstype=(value)
      raise "Can not modify fstype of images"
  end

end
