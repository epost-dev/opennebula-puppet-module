require 'beaker-rspec'
require 'pry'

hosts.each do |host|
  # Install Puppet
  install_package host, 'rubygems'
  on host, 'gem install puppet --no-ri --no-rdoc'
  on host, "mkdir -p #{host['distmoduledir']}"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Configure EPEL if appropriate.
    if fact('osfamily') == 'RedHat'
      pp = <<-EOS
        if $::osfamily == 'RedHat' {
          yumrepo {'epel':
            descr    => "Extra Packages for Enterprise Linux ${::operatingsystemmajrelease} - \\$basearch",
            baseurl  => "http://download.fedoraproject.org/pub/epel/${::operatingsystemmajrelease}/\\$basearch",
            enabled  => 1,
            gpgkey   => "http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}",
            gpgcheck => 1,
          }
        }
      EOS

      apply_manifest_on(hosts, pp, :catch_failures => false)
    end

    hosts.each do |host|
      # Install module
      copy_module_to(host, :source => proj_root, :module_name => 'one')

      # Configure hiera
      on host, "/bin/touch #{default['puppetpath']}/hiera.yaml"
      on host, "mkdir -p /var/lib/hiera"
      on host, "echo -e '---\none::enable_opennebula_repo: true\none::ha_setup: false\n' > /var/lib/hiera/common.yaml"

      # Install dependencies
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
