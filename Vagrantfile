# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # => vagrant plugin install vagrant-proxyconf
  if Vagrant.has_plugin?('vagrant-proxyconf')
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
      config.proxy.no_proxy = 'localhost,127.0.0.1'
    end
  end

  # => vagrant plugin install vagrant-cachier
  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box

    # OPTIONAL: If you are using VirtualBox, you might want to use that to enable
    # NFS for shared folders. This is also very useful for vagrant-libvirt if you
    # want bi-directional sync
    config.cache.synced_folder_opts = {
      type: :nfs,
      # The nolock option can be useful for an NFSv3 client that wants to avoid the
      # NLM sideband protocol. Without this option, apt-get might hang if it tries
      # to lock files needed for /var/cache/* operations. All of this can be avoided
      # by using NFSv4 everywhere. Please note that the tcp option is not the default.
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
    # For more information please check http://docs.vagrantup.com/v2/synced-folders/basic_usage.html
  end

  config.vm.network "private_network", type: "dhcp"

  config.vm.synced_folder '.', '/etc/puppet/modules/one/'

  config.vm.define 'centos' do |centos|
    centos.vm.box = 'puppetlabs/centos-6.6-64-puppet'
    config.vm.box_version = '1.0.1'
    centos.vm.provision 'shell', inline: '/usr/bin/yum -y install epel-release'
    centos.vm.provision 'shell', inline: 'puppet module install puppetlabs-stdlib'
    centos.vm.provision 'shell', inline: 'puppet module install puppetlabs-inifile'
    centos.vm.provision 'puppet' do |puppet|
      puppet.manifests_path = 'manifests'
      puppet.manifest_file = 'init.pp'
      puppet.options = [
          '--verbose',
          "-e 'class { one: oned => true, sunstone => true, }'"
      ]
    end
  end

  config.vm.define 'debian' do |debian|
    debian.vm.box = 'puppetlabs/debian-7.8-64-puppet'
    debian.vm.provision 'shell', inline: 'puppet module install puppetlabs-stdlib'
    debian.vm.provision 'shell', inline: 'puppet module install puppetlabs-inifile'
    debian.vm.provision 'shell', inline: 'puppet module install puppetlabs-apt'
    debian.vm.provision 'puppet' do |puppet|
      puppet.manifests_path = 'manifests'
      puppet.manifest_file = 'init.pp'
      puppet.options = [
          '--verbose',
          "-e 'class { one: oned => true, sunstone => true, }'"
      ]
    end
  end
end
