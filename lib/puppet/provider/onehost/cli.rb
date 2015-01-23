require 'nokogiri'

Puppet::Type.type(:onehost).provide(:cli) do
  desc "onehost provider"

  has_command(:onehost, "onehost") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  def create
    onehost('create', resource[:name], '--im', resource[:im_mad], '--vm', resource[:vm_mad], '--net', resource[:vn_mad])
    @property_hash[:ensure] = :present
  end

  def destroy
    onehost('delete', resource[:name])
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.instances
     Nokogiri::XML(onehost('list','-x')).root.xpath('/HOST_POOL/HOST') do | host|
       new(
           :name   => host.xpath('./NAME').text,
           :ensure => :present,
           :im_mad => host.xpath('./IM_MAD').text,
           :vm_mad => host.xpath('./VM_MAD').text,
           :vn_mad => host.xpath('./VN_MAD').text
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
