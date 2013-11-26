require 'test/unit'
require 'mocha/setup'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'hiera-puppet-helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

# include common helpers
support_path = File.expand_path(File.join(File.dirname(__FILE__), '..',
                                          'spec/support/*.rb'))
Dir[support_path].each {|f| require f}

RSpec.configure do |c|
  c.config = '/doesnotexist'
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.mock_with :mocha
end

shared_context "hieradata" do
  let(:hiera_config) do
    { :backends => ['rspec', 'yaml'],
      :hierarchy => [ 'test' ],
      :yaml => {
        :datadir => File.join(fixture_path, 'hiera') },
      :rspec => respond_to?(:hiera_data) ? hiera_data : {} }
  end
end

