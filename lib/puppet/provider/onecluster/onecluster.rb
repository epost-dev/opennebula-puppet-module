require 'rexml/document'
#require 'tempfile'
#require 'erb'

Puppet::Type.type(:onecluster).provide(:onecluster) do
  desc "onecluster provider"

  commands :onecluster => "onecluster"

  def create
    output = "onecluster create #{resource[:name]} ", self.class.login()
    `#{output}`
    # clusterhosts = resource[:hosts]
    if resource[:hosts].to_a != []
        self.debug "We have hosts: #{resource[:hosts]}"
        resource[:hosts].to_a.each { |host|
          host_command = "onecluster addhost #{resource[:name]} #{host} ", self.class.login()
          `#{host_command}`
        }
    end
    if resource[:vnets].to_a != []
        resource[:vnets].each { |vnet|
            vnet_command = "onecluster addvnet #{resource[:name]} #{vnet} ", self.class.login()
            `#{vnet_command}`
        }
    end
    if resource[:datastores].to_a != []
        resource[:datastores].each { |datastore|
            ds_command = "onecluster adddatastore #{resource[:name]} #{datastore} ", self.class.login()
            `#{ds_command}`
        }
    end
  end

  def destroy
      hosts_output = "onecluster show #{resource[:name]} --xml ", self.class.login()
      xml = REXML::Document.new(`#{hosts_output}`)
      self.debug "Removing hosts vnets and datastores from cluster #{resource[:name]}"
      xml.elements.each("CLUSTER/HOSTS/ID") { |host|
          host_command = "onecluster delhost #{resource[:name]} #{host.text} ", self.class.login
          `#{host_command}`
      }
      xml.elements.each("CLUSTER/VNETS/ID") { |vnet|
          vnet_command = "onecluster delvnet #{resource[:name]} #{vnet.text} ", self.class.login
          `#{vnet_command}`
      }
      xml.elements.each("CLUSTER/DATASTORES/ID") { |ds|
          ds_command = "onecluster deldatastore #{resource[:name]} #{ds.text} ", self.class.login
          `#{ds_command}`
      }
      output = "onecluster delete #{resource[:name]} ", self.class.login()
      self.debug "Running command #{output}"
      `#{output}`
  end

  def exists?
    self.class.onecluster_list().include?(resource[:name])
  end

  def self.onecluster_list
    xml = REXML::Document.new(`onecluster list -x`)
    list = []
    xml.elements.each("CLUSTER_POOL/CLUSTER/NAME") do |cluster|
      list << cluster.text
    end
    list
  end

  def self.instances
    instances = []

    onecluster_list().each do |cluster|
      hash = {}
      hash[:provider] = self.class.name.to_s
      hash[:name] = cluster
      output = "onecluster list --xml ", login
      xml = REXML::Document.new(`#{output}`)
      xml.elements.each("CLUSTER/VNETS") { |element|
          hash[:vnets] = element.text.to_a
      }
      xml.elements.each("CLUSTER/HOSTS") { |element|
          hash[:hosts] = element.text
      }
      xml.elements.each("CLUSTER/DATASTORES") { |element|
          hash[:datastores] = element.text.to_a
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
  def hosts
      result = []
      getter_output = "onecluster show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{getter_output}`)
      xml.elements.each("CLUSTER/HOSTS/ID") { |element|
          host_getter_output = "onehost show #{element.text} --xml ", self.class.login
          host_xml = REXML::Document.new(`#{host_getter_output}`)
          host_xml.elements.each("HOST/NAME") { |host_element|
            result << host_element.text
          }
      }
      result
  end
  def vnets
      result = []
      getter_output = "onecluster show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{getter_output}`)
      xml.elements.each("CLUSTER/VNETS/ID") { |element|
          vnet_getter_output = "onevnet show #{element.text} --xml ", self.class.login
          vnet_xml = REXML::Document.new(`#{vnet_getter_output}`)
          vnet_xml.elements.each("VNET/NAME") { |vnet_element|
            result << vnet_element.text
          }
      }
      result
  end
  def datastores
      result = []
      getter_output = "onecluster show #{resource[:name]} --xml ", self.class.login
      xml = REXML::Document.new(`#{getter_output}`)
      xml.elements.each("CLUSTER/DATASTORES/ID") { |element|
          ds_getter_output = "onedatastore show #{element.text} --xml ", self.class.login
          ds_xml = REXML::Document.new(`#{ds_getter_output}`) { |ds_element|
            result << ds_element.text
          }
      }
      result
  end

  #setters
  def hosts=(value)
  end
  def vnets=(value)
  end
  def datastores=(value)
  end
end
