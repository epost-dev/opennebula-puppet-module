require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:oneimage).provide(:cli) do
  desc "oneimage provider"

  has_command(:oneimage, "oneimage") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  # Create a network with onevnet by passing in a temporary template.
  def create
    file = Tempfile.new("oneimage-#{resource[:name]}")
    File.chmod(0644, file.path)

    template = ERB.new <<-EOF
NAME = "<%= resource[:name] %>"
<% if resource[:description] %>DESCRIPTION = "<%= resource[:description] %>"<% end%>
<% if resource[:type]        %>TYPE = <%=         resource[:type].to_s.upcase %><% end%>
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
    oneimage('create', '-d', resource[:datastore], file.path)
    @property_hash[:ensure] = :present
  end

  # Destroy a network using onevnet delete
  def destroy
    oneimage('delete', resource[:name])
    @property_hash.clear
  end

  # Check if a network exists by scanning the onevnet list
  def exists?
    @property_hash[:ensure] == :present
  end

  # Return the full hash of all existing oneimage resources
  def self.instances
    REXML::Document.new(oneimage('list', '-x')).elements.collect("IMAGE_POOL/IMAGE") do |image|
      elements = image.elements
      new(
        :name        => elements["NAME"].text,
        :ensure      => :present,
        :datastore   => elements["DATASTORE"].text,
        :description => elements["TEMPLATE/DESCRIPTION"].text,
        :dev_prefix  => elements["TEMPLATE/DEV_PREFIX"].text,
        :disk_type   => elements["DISK_TYPE"].text,
        :driver      => (elements["DRIVER"].text unless elements["DRIVER"].nil?),
        :fstype      => elements["FSTYPE"].text,
        :path        => (elements["TEMPLATE/PATH"] || elements["PATH"]).text,
        :persistent  => ((elements["TEMPLATE/PERSISTENT"] || elements["PERSISTENT"]).text == "1").to_s.to_sym,
        :size        => elements["SIZE"].text,
        :source      => (elements["TEMPLATE/SOURCE"] || elements["SOURCE"]).text,
        :target      => (elements["TARGET"].text unless elements["TARGET"].nil?),
        :type        => {
          '0' => :OS,
          '1' => :CDROM,
          '5' => :CONTEXT,
        }[(elements["TEMPLATE/TYPE"] || elements["TYPE"]).text]
      )
    end
  end

  def self.prefetch(resources)
    images = instances
    resources.keys.each do |name|
      if provider = images.find{ |image| image.name == name }
        resources[name].provider = provider
      end
    end
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
