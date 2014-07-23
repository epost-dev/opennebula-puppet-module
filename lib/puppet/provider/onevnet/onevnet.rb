require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onevnet).provide :onevnet do
  desc "onevnet provider"

  commands :onevnet => "onevnet"


  # Create a network with onevnet by passing in a temporary template.
  def create
    file = Tempfile.new("onevnet-#{resource[:name]}")
    template = ERB.new <<-EOF
NAME = "<%= resource[:name] %>"
TYPE = <%= resource[:type].upcase %>
BRIDGE = <%= resource[:bridge] %>

<% if resource[:protocol].upcase == "IPV4" %>
# IPV4
<% if resource[:type].upcase == "FIXED" %>
# FIXED NETWORK IPV4
<% resource[:leases].each { |lease| %>
LEASES = [IP=<%= lease%>]
<% } %>
<% elsif resource[:type].upcase == "RANGED" %>
# RANGED NETWORK IPV4
NETWORK_SIZE = <%= resource[:network_size] %>
NETWORK_ADDRESS = <%= resource[:network_address] %>
<% end %>
<% elsif resource[:protocol].upcase == "IPV6" %>
# IPV6
<% if resource[:type].upcase == "FIXED" %>
# FIXED NETWORK IPV6
<% resource[:leases].each { |lease| %>
#LEASES = 
<% elsif resource[:type].upcase == "RANGED" %>
# RANGED NETWORK IPV6
MAC_START = <%= resource[:macstart] %>
NETWORK_SIZE = <%= resource[:network_size] %>
SITE_PREFIX = <%= resource[:siteprefix] %>
GLOBAL_PREFIX = <%= resource[:globalprefix] %>

# Context information
<% resource[:context].each { |key,value| %>
<%= key.upcase %> = <%= value %>
<% } %>
EOF

    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "create", file.path, self.class.login()
    file.delete
  end

  # Destroy a network using onevnet delete
  def destroy
    onevnet "delete", resource[:name], self.class.login()
  end

  # Return a list of existing networks using the onevnet -x list command
  def self.onevnet_list
    xml = REXML::Document.new(onevnet "list -x", self.class.login())
    onevnets = []
    xml.elements.each("VNET_POOL/VNET/NAME") do |element|
      onevnets << element.text
    end
    onevnets
  end

  # Check if a network exists by scanning the onevnet list
  def exists?
    self.class.onevnet_list().include?(resource[:name])
  end

  # Return the full hash of all existing onevnet resources
  def self.instances
    instances = []
    onevnet_list.each do |vnet|
      hash = {}

      # Obvious resource attributes
      hash[:provider] = self.name.to_s
      hash[:name] = vnet

      # Open onevnet xml output using REXML
      xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())

      # Traverse the XML document and populate the common attributes
      xml.elements.each("VNET/TYPE") { |element|
        hash[:type] = element.text == "1" ? "fixed" : "ranged"
      }
      xml.elements.each("VNET/BRIDGE") { |element|
        hash[:bridge] = element.text
      }
      xml.eletments.each("VNET/VLAN_ID") { |element|
        hash[:vlanid] = element.text
      }
      xml.elements.each("VNET/PUBLIC") { |element|
        hash[:public] = element.text == "1" ? true : false
      }

      # Populate ranged or fixed specific resource attributes
      if hash[:type] == "ranged" then
        xml.elements.each("VNET/TEMPLATE/NETWORK_MASK") { |element|
          hash[:network_size] = element.text
        }
        xml.elements.each("VNET/TEMPLATE/NETWORK_ADDRESS") { |element|
          hash[:network_address] = element.text
          hash[:protocol] = 'ipv4'
        }
        xml.elements.each("VNET/TEMPLATE/IP_START") { |element|
          hash[:network_start] = element
        }
        xml.elements.each("VNET/TEMPLATE/IP_END") { |element|
          hash[:network_end] = element
        } 
        xml.elements.each("VNET/TEMPLATE/GLOBAL_PREFIX") { |element|
          if element == '' then
            xml.elements.each("VNET/GLOBAL_PREFIX") { |element2|
                hash[:globalprefix] = element2
                if element2 != '' then
                    hash[:protocol] = 'ipv6'
                end
            }
          else
            hash[:globalprefix] = element
            hash[:protocol] = 'ipv6'
          end
        }
        xml.elements.each("VNET/TEMPLATE/SITE_PREFIX") { |element|
          if element == '' then
            xml.elements.each("VNET/SITE_PREFIX") { |element2|
                hash[:siteprefix] = element2
                if element2 != '' then
                  hash[:protocol] = 'ipv6'
                end
            }
          else
            hash[:siteprefix] = element
          end
        }
      elsif hash[:type] == "fixed"
        hash[:leases] = []
        xml.elements.each("VNET/LEASES/LEASE/IP") { |element|
          hash[:leases] << element.text
        }
      end

      instances << new(hash)
    end

    instances
  end

  # login credentials
  def login
    login = " --user #{resource[:user]} --password #{resource[:password]}"
    login
  end

  # getters
  def network_address
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/TEMPLATE/NETWORK_ADDRESS") { |element|
        element.text
    }
  end
  def network_mask
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/TEMPLATE/NETWORK_MASK") { |element|
        element.text
    }
  end
  def siteprefix
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/SITE_PREFIX") { |element|
        element.text
    }
  end
  def globalprefix
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/GLOBAL_PREFIX") { |element|
        element.text
    }
  end
  def dnsservers
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/TEMPLATE/DNSSERVERS") { |element|
        element.text.to_a?
    }
  end
  def gateway
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/TEMPLATE/GATEWAY") { |element|
        element.text
    }
  end
  def type
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/TYPE") { |element|
        result = element.text.upcase == 'FIXED' ? '1' : '0'
        result
    }
  end
  def network_start
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/RANGE/IP_START") { |element|
        element.text
    }
  end
  def network_end
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/RANGE/IP_END") { |element|
        element.text
    }
  end
  def network_size
  # needs to be done
  end
  def macstart
  # needs to be done
  end
  def leases
  # needs to be done
  end
  def model
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/TEMPLATE/MODEL") { |element|
        element.text
    }
  end
  def vlanid
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/TEMPLATE/VLAN_ID") { |element|
        element.text
    }
  end
  def bridge
    xml = REXML::Document.new(onevnet "show", vnet, " -x ", self.class.login())
    xml.elements.each("VNET/BRIDGE") { |element|
        element.text
    }
  end

  # setters
  def network_address=(value)
    file = Tempfile.new("onevnet-network_address-#{resource[:name]}")
    template = ERB.new <<-EOF
NETWORK_ADDRESS = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def network_mask=(value)
    file = Tempfile.new("onevnet-network_mask-#{resource[:name]}")
    template = ERB.new <<-EOF
NETWORK_MASK = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def siteprefix=(value)
    file = Tempfile.new("onevnet-siteprefix-#{resource[:name]}")
    template = ERB.new <<-EOF
SITE_PREFIX = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def globalprefix=(value)
    file = Tempfile.new("onevnet-globalprefix-#{resource[:name]}")
    template = ERB.new <<-EOF
GLOBAL_PREFIX = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def dnsservers=(value)
    file = Tempfile.new("onevnet-dnsservers-#{resource[:name]}")
    template = ERB.new <<-EOF
DNSSERVERS = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def gateway=(value)
    file = Tempfile.new("onevnet-gateway-#{resource[:name]}")
    template = ERB.new <<-EOF
GATEWAY = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def type=(value)
    file = Tempfile.new("onevnet-type-#{resource[:name]}")
    template = ERB.new <<-EOF
TYPE = <% value.upcase == 'FIXED' ? '1' : '0' %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def network_start=(value)
    file = Tempfile.new("onevnet-network_start-#{resource[:name]}")
    template = ERB.new <<-EOF
IP_START = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def network_end=(value)
    file = Tempfile.new("onevnet-network_end-#{resource[:name]}")
    template = ERB.new <<-EOF
IP_END = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def model=(value)
    file = Tempfile.new("onevnet-model-#{resource[:name]}")
    template = ERB.new <<-EOF
MODEL = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def vlanid=(value)
    file = Tempfile.new("onevnet-vlanid-#{resource[:name]}")
    template = ERB.new <<-EOF
VLAN_ID = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
  def bridge=(value)
    file = Tempfile.new("onevnet-bridge-#{resource[:name]}")
    template = ERB.new <<-EOF
BRIDGE = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    onevnet "update", resource[:name], file.path, self.class.login()
    file.delete
  end
end
