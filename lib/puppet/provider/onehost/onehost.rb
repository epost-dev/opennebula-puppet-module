require 'rexml/document'

Puppet::Type.type(:onehost).provide(:onehost) do
  desc "onehost provider"

  commands :onehost => "onehost"

  def create
    onehost "create", resource[:name], resource[:im_mad], resource[:vm_mad],
      resource[:tm_mad]
  end

  def destroy
    onehost "delete", resource[:name]
  end

  def self.onehost_list
    xml = REXML::Document.new(`onehost -x list`)
    onehosts = []
    xml.elements.each("HOST_POOL/HOST/NAME") do |element|
      onehosts << element.text
    end
    onehosts
  end

  def exists?
    self.class.onehost_list().include?(resource[:name])
  end

  def self.instances
    instances = []
    onehost_list().each do |host|
      hash = {}
      hash[:provider] = self.name.to_s
      hash[:name] = host

      xml = REXML::Document.new(`onehost -x show #{host}`)
      xml.elements.each("HOST/IM_MAD") { |element| hash[:im_mad] = element.text }
      xml.elements.each("HOST/VM_MAD") { |element| hash[:vm_mad] = element.text }
      xml.elements.each("HOST/TM_MAD") { |element| hash[:tm_mad] = element.text }

      instances << new(hash)
    end

    instances
  end
end
