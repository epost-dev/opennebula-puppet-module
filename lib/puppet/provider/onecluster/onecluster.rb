require 'rexml/document'

Puppet::Type.type(:onecluster).provide(:onecluster) do
  desc "onecluster provider"

  commands :onecluster => "onecluster"

  def create
    onecluster "create", resource[:name], self.class.login()
  end

  def destroy
    onecluster "delete", resource[:name], self.class.login()
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
      instances << new(hash)
    end

    instances
  end

  # login credentials
  def login
    login = " --user #{resource[:user]} --password #{resource[:password]}"
    login
  end

  #getters
  def host
  end
  def vnet
  end
  def datastore
  end

  #setters
  def host=(value)
  end
  def vnet=(value)
  end
  def datastore=(value)
  end
end
