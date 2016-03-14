require 'mocha/setup'
require 'rspec-puppet'
require 'rspec-puppet-utils'
require 'hiera'
require 'facter'
require 'puppetlabs_spec_helper/module_spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

# include common helpers
support_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec/support/*.rb'))
Dir[support_path].each { |f| require f }

RSpec.configure do |c|
  c.config = '/doesnotexist'
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.hiera_config = File.join(fixture_path, 'hiera/hiera.yaml')
  c.mock_with :mocha
end

OS_FACTS = [
    {
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS',
        :operatingsystemmajrelease => '6'
    },
    {
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS',
        :operatingsystemmajrelease => '7'
    },
    {
        :osfamily => 'Debian',
        :lsbdistid => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemmajrelease => '7'
    },
]

at_exit { RSpec::Puppet::Coverage.report! }
