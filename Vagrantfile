# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # => vagrant plugin install vagrant-proxyconf
  if Vagrant.has_plugin?("vagrant-proxyconf")
    has_proxy = false
    if ENV.has_key?('http_proxy') and !ENV['http_proxy'].empty?
      config.proxy.http = ENV['http_proxy']
      has_proxy = true
    end
    if ENV.has_key?('https_proxy') and !ENV['https_proxy'].empty?
      config.proxy.https = ENV['https_proxy']
      has_proxy = true
    end
    if has_proxy
      config.proxy.no_proxy = "localhost,127.0.0.1"
    end
  end

  config.vm.synced_folder ".", "/etc/puppet/modules/one/"

  config.vm.define "centos" do |centos|
    centos.vm.box = "centos65_64"
    centos.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box'
    centos.vm.provision "shell", inline: '/usr/bin/yum -y install puppet epel-release'
    centos.vm.provision "shell", inline: 'puppet module install puppetlabs-stdlib'
    centos.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "init.pp"
      puppet.options = [
          '--verbose',
          "-e 'class { one: oned => true, node => false, sunstone => true, }'"
      ]
    end
  end
end
