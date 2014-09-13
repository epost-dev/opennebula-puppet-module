require 'rexml/document'
require 'erb'
require 'tempfile'

Puppet::Type.type(:onehost).provide(:onehost) do
  desc "onehost provider"

  commands :onehost => "onehost"

  mk_resource_methods

  def create
    output = "onehost create #{resource[:name]} --im #{resource[:im_mad]} --vm #{resource[:vm_mad]} --net #{resource[:vn_mad]} ", self.class.login
    `#{output}`
    @property_hash[:ensure] = :present
  end

  def destroy
    output = "onehost delete #{resource[:name]} ", self.class.login
    `#{output}`
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.instances
    output = "onehost list -x ", login
    REXML::Document.new(`#{output}`).elements.collect("HOST_POOL/HOST") do |host|
      new(
        :name   => host.elements["NAME"].text,
        :ensure => :present,
        :im_mad => host.elements["IM_MAD"].text,
        :vm_mad => host.elements["VM_MAD"].text,
        :vn_mad => host.elements["VN_MAD"].text
      )
    end
  end

  def self.prefetch(resources)
    hosts = instances
    resources.keys.each do |name|
      if provider = hosts.find{ |host| host.name == name }
        resources[name].provider = provider
      end
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

  # setters
  def im_mad=(value)
     raise "onehosts can not be updated. You have to remove and recreate the host"
  end

  def vm_mad=(value)
     raise "onehosts can not be updated. You have to remove and recreate the host"
  end

  def vn_mad=(value)
     raise "onehosts can not be updated. You have to remove and recreate the host"
  end

end
