require 'puppet/provider/one'

Puppet::Type.type(:onehost).provide(:cli, :parent => Puppet::Provider::One) do
  desc "onehost provider"

  mk_resource_methods

  def create
    xml  = OpenNebula::Host.build_xml
    host = OpenNebula::Host.new(xml, client)
    rc   = host.allocate(resource[:name], resource[:im_mad], resource[:vm_mad], resource[:vn_mad])
    raise Puppet::Error, rc.message if OpenNebula.is_error?(rc)
    rc = host.info
    raise Puppet::Error, rc.message if OpenNebula.is_error?(rc)
    @property_hash[:ensure] = :present
  end

  def destroy
    host_pool = OpenNebula::HostPool.new(client)
    rc = host_pool.info
    raise Puppet::Error, rc.message if OpenNebula.is_error?(rc)
    host = host_pool.select { |h| h.name == resource[:name] }[0]
    rc = host.info
    raise Puppet::Error, rc.message if OpenNebula.is_error?(rc)
    host.delete
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.instances
    host_pool = OpenNebula::HostPool.new(client)
    rc = host_pool.info
    raise Puppet::Error, rc.message if OpenNebula.is_error?(rc)
    Array[host_pool.to_hash['HOST_POOL']['HOST']].flatten.map do |host|
      new(
        :name   => host['NAME'],
        :ensure => :present,
        :im_mad => host['IM_MAD'],
        :vm_mad => host['VM_MAD'],
        :vn_mad => host['VN_MAD']
      )
    end if host_pool.to_hash['HOST_POOL']
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
