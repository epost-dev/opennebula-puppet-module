# OpenNebula Puppet provider for onehost
#
# License: APLv2
#
# Authors:
# Based upon initial work from Ken Barber
# Modified by Martin Alfke
#
# Copyright
# initial provider had no copyright
# Deutsche Post E-POST Development GmbH - 2014, 2015
#

require 'rubygems'
require 'nokogiri'

Puppet::Type.type(:onehost).provide(:cli) do
  desc "onehost provider"

  commands(:onehost => "onehost", :onecluster => "onecluster") do
    environment :HOME => '/root', :ONE_AUTH => '/var/lib/one/.one/one_auth'
  end

  mk_resource_methods

  def create
    if resource[:cluster_id].to_s == "-1"
      onehost('create', resource[:name], '--im', resource[:im_mad], '--vm', resource[:vm_mad], '--net', resource[:vn_mad])
    else
      onehost('create', resource[:name], '--im', resource[:im_mad], '--vm', resource[:vm_mad], '--net', resource[:vn_mad], '--cluster', resource[:cluster_id])
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    onehost('delete', resource[:name])
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def disable
    onehost('disable', resource[:name])
  end

  def enable
    onehost('enable', resource[:name])
  end

  def add_to_cluster
    onecluster("addhost", resource[:cluster_id], resource[:name])
  end

  def delete_from_cluster
    onecluster("delhost", @property_hash[:cluster_id], resource[:name])
  end

  def switch_cluster
    delete_from_cluster
    add_to_cluster
  end

  def validate_cluster
    clusters  = Nokogiri::XML(onecluster("list", "-x")).root.xpath('/CLUSTER_POOL/CLUSTER')
    cluster_ids = Array.new
    clusters.each do | name |
      cluster_ids << name.xpath("./ID").text
    end
    if cluster_ids.include? resource[:cluster_id].to_s
      return true
    else
      return false
    end
  end

  def self.instances
     hosts = Nokogiri::XML(onehost('list','-x')).root.xpath('/HOST_POOL/HOST')
     hosts.collect do |host|
       new(
           :name   => host.xpath('./NAME').text,
           :ensure => :present,
           :im_mad => host.xpath('./IM_MAD').text,
           :vm_mad => host.xpath('./VM_MAD').text,
           :vn_mad => host.xpath('./VN_MAD').text,
           :cluster_id => host.xpath('./CLUSTER_ID').text,
           :status => {'0' => 'init', '2' => 'enabled','3' => 'error', '4' => 'disabled'}[host.xpath('./STATE').text]
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

  def status=(value)
     if resource[:status] == "enabled" and @property_hash[:status] == "disabled"
       enable
     elsif @property_hash[:status] != "disabled" and resource[:status] == "disabled"
       disable
     else
       raise "Onehosts cannot be updated. Cannot recover from state: " + @property_hash[:status]
     end
  end

  def cluster_id=(value)
    if resource[:status] == "error"
      raise "Host in wrong state to perform update on Cluster ID"
    elsif value.to_s == "-1" and @property_hash[:cluster_id].to_s != "-1"
      delete_from_cluster
    elsif validate_cluster==false
      raise "Onehost cannot be updated. Invalid Cluster ID"
    elsif @property_hash[:cluster_id].to_s == "-1"
      add_to_cluster
    else
      switch_cluster
    end
  end

end
