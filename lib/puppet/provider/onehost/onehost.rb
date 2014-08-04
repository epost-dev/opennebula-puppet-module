require 'rexml/document'

Puppet::Type.type(:onehost).provide(:onehost) do
  desc "onehost provider"

  commands :onehost => "onehost"

  def create
    output = "onehost create #{resource[:name]} --im #{resource[:im_mad]} --vm #{resource[:vm_mad]} --net #{resource[:net_mad]} ", self.class.login
    `#{output}`
  end

  def destroy
    output = "onehost delete #{resource[:name]} ", self.class.login
    `#{output}`
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

  # login credentials
  def self.login
    credentials = File.read('/var/lib/one/.one/one_auth').strip.split(':')
    user = credentials[0]
    password = credentials[1]
    login = " --user #{user} --password #{password}"
    login
  end

  # getters
  def im_mad
  end

  def vm_mad
  end

  def tm_mad
  end

  def net_mad
  end

  # setters
  def im_mad=(value)
  end

  def vm_mad=(value)
  end

  def tm_mad=(value)
  end

  def net_mad=(value)
  end

end
