require 'rexml/document'

Puppet::Type.type(:onecluster).provide(:onecluster) do
  desc "onecluster provider"

  commands :onecluster => "onecluster"

  def create
    onecluster "create", resource[:name]
  end

  def destroy
    onecluster "delete", resource[:name]
  end

  def exists?
    self.class.onecluster_list().include?(resource[:name])
  end

  def self.onecluster_list
    xml = REXML::Document.new(`onecluster -x list`)
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
end
