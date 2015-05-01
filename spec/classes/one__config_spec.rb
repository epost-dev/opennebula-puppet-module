require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::config' do
  context 'general' do
    let(:params) { {
    } }
    it { should contain_file('/var/lib/one') \
                    .with_ensure('directory') \
                    .with_owner('oneadmin') \
                    .with_group('oneadmin')
    }
  end
end