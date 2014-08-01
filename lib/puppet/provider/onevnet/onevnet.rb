# OpenNebula Puppet provider for onevnet
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

# require section:
# we read onevnet structure by using xml
# we write tempfiles as erb templates for creating resources and setting properties
#
require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onevnet).provide :onevnet do
  desc "onevnet provider"

  # we only define the command, but we will not use it
  # ruby seems to have an ugly way to append options to commands.
  # this is only used as a confine so we run this provider only if the command is available.
  commands :onevnet => "onevnet"

  # we can not use the mk_reosurce_methods helper.
  # opennebula has different ways of getting and reading properties.
  #  mk_resource_methods

  # Create a network with onevnet by passing in a temporary template.
  def create
    file = Tempfile.new("onevnet-#{resource[:name]}")
    template = ERB.new <<-EOF
NAME = "<%= resource[:name] %>"
TYPE = <%= resource[:type].upcase %>
BRIDGE = <%= resource[:bridge] %>

<% if resource[:phydev] %>
PHYDEV = <%= resource[:phydev] %>
<% end %>
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
    output = "onevnet create #{file.path} ", self.class.login
    `#{output}`
    file.delete
  end

  # Destroy a network using onevnet delete
  def destroy
    output = "onevnet delete #{resource[:name]} ", self.class.login
    `#{output}`
  end

  # Return a list of existing networks using the onevnet -x list command
  def self.onevnet_list
    output = "onevnet list --xml", login
    xml = REXML::Document.new(`#{output}`)
    onevnets = []
    xml.elements.each("VNET_POOL/VNET/NAME") do |element|
      onevnets << element.text
      self.debug "Found vnet : #{element}"
    end
    onevnets
  end

  # Check if a network exists by scanning the onevnet list
  def exists?
    self.class.onevnet_list().include?(resource[:name])
  end

#  # Return the full hash of all existing onevnet resources
  def self.instances
    instances = []
    onevnet_list.each do |vnet|
#    output = "onevnet list --xml", login
#    doc = REXML::Document.new(`#{output}`)
#    doc.elements.each("VNET_POOL/VNET/NAME") do |element|
#     vnet = element.text
      hash = {}
      self.debug "Getting properties for vnet : #{vnet}"

      # Obvious resource attributes
      hash[:provider] = self.name.to_s
      hash[:name] = vnet

      # Open onevnet xml output using REXML
      output = "onevnet show #{vnet} --xml", login
      xml = REXML::Document.new(`#{output}`)
#      doc.each_element_with_text("#{vnet}", 1, 'VNET_POOL/VNET/NAME') { |name|
#	vnetelement = name.parent
#	xml = REXML::Document.new()
#	xml.add_element(vnetelement)

	# Traverse the XML document and populate the common attributes
	xml.elements.each("VNET/TYPE") { |element|
	  hash[:type] = element.text == "1" ? 'fixed' : 'ranged'
	}
	xml.elements.each("VNET/BRIDGE") { |element|
          hash[:bridge] = element.text
	}
        xml.elements.each("VNET/TEMPLATE/BRIDGE") { |element|
          hash[:bridge] = element.text
        }
	xml.elements.each("VNET/PHYDEV") { element|
	  hash[:phydev] = element.text
	}
        xml.elements.each("VNET/TEMPLATE/PHYDEV") { |element|
          hash[:phydev] = element.text
        }
	xml.elements.each("VNET/VLAN_ID") { |element|
          hash[:vlanid] = element.text
	}
	xml.elements.each("VNET/TEMPLATE/VLAN_ID") { |element|
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
          # IP_START can either be set during creating (in RANGE section)
          # or modified afterwards and be set in TEMPLATE section
          xml.elements.each("VNET/RANGE/IP_START") { |element|
            hash[:network_start] = element.text
          }
          xml.elements.each("VNET/TEMPLATE/IP_START") { |element|
            hash[:network_start] = element.text
          }
          # IP_END can either be set during creating (in RANGE section)
          # or modified afterwards and be set in TEMPLATE section
          xml.elements.each("VNET/RANGE/IP_END") { |element|
            hash[:network_end] = element.text
          } 
          xml.elements.each("VNET/TEMPLATE/IP_END") { |element|
            hash[:network_end] = element.text
          } 
          # GLOBAL_PREFIX can either be set during creating (in VNET section)
          # or modified afterwards and be set in TEMPLATE section
          xml.elements.each("VNET/GLOBAL_PREFIX") { |element|
            hash[:globalprefix] = element.text
              hash[:protocol] = 'ipv6'
          }
          xml.elements.each("VNET/TEMPLATE/GLOBAL_PREFIX") { |element|
            hash[:globalprefix] = element.text
              hash[:protocol] = 'ipv6'
          }
          # SITE_PREFIX can either be set during creating (in VNET section)
          # or modified afterwards and be set in TEMPLATE section
          xml.elements.each("VNET/SITE_PREFIX") { |element|
            hash[:siteprefix] = element.text
            hash[:protocol] = 'ipv6'
          }
          xml.elements.each("VNET/TEMPLATE/SITE_PREFIX") { |element|
            hash[:siteprefix] = element.text
            hash[:protocol] = 'ipv6'
          }
	elsif hash[:type] == "fixed"
          hash[:leases] = []
          xml.elements.each("VNET/LEASES/LEASE/IP") { |element|
            hash[:leases] << element.text
          }
        end

	instances << new(hash)
#    }
    end
#    instances
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
  def network_address
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/TEMPLATE/NETWORK_ADDRESS") { |element|
        result =  element.text
    }
    result
  end

  def network_mask
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/TEMPLATE/NETWORK_MASK") { |element|
        result = element.text
    }
    result
  end

  def siteprefix
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/SITE_PREFIX") { |element|
        result = element.text
    }
    xml.elements.each("VNET/TEMPLATE/SITE_PREFIX") { |element|
        result = element.text
    }
    result
  end

  def globalprefix
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/GLOBAL_PREFIX") { |element|
        result = element.text
    }
    xml.elements.each("VNET/TEMPLATE/GLOBAL_PREFIX") { |element|
        result = element.text
    }
    result
  end

  def dnsservers
    result = []
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/TEMPLATE/DNSSERVERS") { |element|
        result << element.text.to_a?
    }
    result
  end

  def gateway
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/TEMPLATE/GATEWAY") { |element|
        result = element.text
    }
    result
  end

  def type
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/TYPE") { |element|
        result = element.text == "1" ? "fixed" : "ranged"
    }
    self.debug "Found netowrk type : #{result}"
    result
  end

  def network_start
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/RANGE/IP_START") { |element|
        result = element.text
    }
    xml.elements.each("VNET/TEMPLATE/IP_START") { |element|
	result = element.text
    }
    result
  end

  def network_end
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/RANGE/IP_END") { |element|
        result = element.text
    }
    xml.elements.each("VNET/TEMPLATE/IP_END") { |element|
	result = element.text
    }
    result
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
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/TEMPLATE/MODEL") { |element|
        result = element.text
    }
    result
  end

  def vlanid
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/VLAN_ID") { |element|
        result = element.text
    }
    xml.elements.each("VNET/TEMPLATE/VLAN_ID") { |element|
      result = element.text
    }
    result
  end

  def bridge
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/BRIDGE") { |element|
        result = element.text
    }
    xml.elements.each("VNET/TEMPLATE/BRIDGE") { |element|
      result = element.text
    }
    result
  end

  def phydev
    result = ''
    getter_output = "onevnet show #{resource[:name]} --xml ", self.class.login
    xml = REXML::Document.new(`#{getter_output}`)
    xml.elements.each("VNET/PHYDEV") { |element|
      result = element.text
    }
    xml.elements.each("VNET/TEMPLATE/PHYDEV") { |element|
      result = element.text
    }
    result
  end

  def context
    # todo
  end

  # setters
  def network_address=(value)
    self.debug "Setting", self.name.to_s, " address on resource onevnet #{resource[:name]} to #{value}"
    file = Tempfile.new("onevnet-network_address-#{resource[:name]}")
    template = ERB.new <<-EOF
NETWORK_ADDRESS = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    self.debug "Wrote tempfile: #{file.path} for update of ", self.name.to_s
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    self.debug "Will run #{output} to update ", self.name.to_s
    `#{output}`
    file.delete
  end

  def network_mask=(value)
    self.debug "Setting netowrk mask for resource onevnet #{resource[:name]} to #{value}"
    file = Tempfile.new("onevnet-network_mask-#{resource[:name]}")
    template = ERB.new <<-EOF
NETWORK_MASK = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
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
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
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
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
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
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
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
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
  end

  def type=(value)
    file = Tempfile.new("onevnet-type-#{resource[:name]}")
    template = ERB.new <<-EOF
TYPE = <% value.to_s.upcase == 'FIXED' ? 1 : 0 %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
  end

  def network_start=(value)
    file = Tempfile.new("onevnet-network_start-#{resource[:name]}")
    template = ERB.new <<-EOF
IP_START = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.open
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.close
  end

  def network_end=(value)
    file = Tempfile.new("onevnet-network_end-#{resource[:name]}")
    template = ERB.new <<-EOF
IP_END = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
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
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
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
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
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
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
  end

  def phydev=(value)
    file = Tempfile.new("onevnet-phydev-#{resource[:name]}")
    template = ERB.new <<-EOF
PHYDEV = <%= value %>
EOF
    tempfile = template.result(binding)
    file.write(tempfile)
    file.close
    output = "onevnet update #{resource[:name]} ", file.path, self.class.login, " --append"
    `#{output}`
    file.delete
  end

  def context=(value)
    # todo
  end
end
