# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "chef/centos-6.5"

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

  config.vm.provision "shell", inline: 'rpm -ivh https://yum.puppetlabs.com/el/6.5/products/x86_64/puppetlabs-release-6-10.noarch.rpm'
  config.vm.provision "shell", inline: '/usr/bin/yum -y install puppet'
  config.vm.provision "shell", inline: '/usr/bin/yum -y install epel-release'
  config.vm.provision "shell", inline: 'puppet module install puppetlabs-stdlib'

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "init.pp"
    puppet.options = ['--verbose', "-e 'class { one: oned => true, sunstone => true, }'"]
  end
end