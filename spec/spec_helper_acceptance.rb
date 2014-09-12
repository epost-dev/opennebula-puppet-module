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
    # Install module
    puppet_module_install(:source => proj_root, :module_name => 'one')
    hosts.each do |host|
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
