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
    centos.vm.provision "shell", inline: '/usr/bin/yum -y install epel-release rubygem-nokogiri'
    centos.vm.provision "shell", inline: 'puppet module install puppetlabs-stdlib'
    centos.vm.provision "puppet" do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file  = "init.pp"
      puppet.options = ['--verbose', "-e 'class { one: oned => true, sunstone => true, }
                                          -> onehost { ['host01', 'host02']: ensure  => present }
                                          -> onecluster { 'production': hosts => 'host01' }
                                          -> onedatastore { 'nfs_ds': tm => 'shared', type => 'system_ds' }
                                          -> onevnet { 'Blue_LAN': }
                                          '"]
    end
  end

  config.vm.define "debian" do |debian|
      debian.vm.box = "puppetlabs/debian-7.8-64-puppet"
      debian.vm.provision "shell", inline: 'puppet module install puppetlabs-stdlib'
      debian.vm.provision "shell", inline: 'puppet module install puppetlabs-apt'
      debian.vm.provision "puppet" do |puppet|
        puppet.manifests_path = "manifests"
        puppet.manifest_file  = "init.pp"
        puppet.options = ['--verbose', "-e 'class { one: oned => true, sunstone => true, }'"]
      end
    end
end
