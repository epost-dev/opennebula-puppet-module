require 'beaker-rspec'
require 'pry'

hosts.each do |host|
  # Install Puppet
  install_puppet
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

      if fact('osfamily') == 'RedHat'
        on host, "yum -y install rubygem-nokogiri"
        on host, "yum clean all"
        on host, "rm -rf /etc/yum.repos.d/puppetlabs.repo"
      end

      # Configure hiera
      on host, "echo -e 'one::enable_opennebula_repo: true' > /etc/puppet/hiera.yaml"

      # Install dependencies
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
