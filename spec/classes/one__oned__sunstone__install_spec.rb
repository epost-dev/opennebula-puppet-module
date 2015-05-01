require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::oned::sunstone::install' do
  let (:facts) { {:osfamily => 'RedHat'} }
  let (:hiera_config) { hiera_config }
  let (:params) {{ :oned_sunstone_packages => 'bogus-package'}}
  context 'general' do
    it { should contain_class('one::oned::sunstone::install')}
    it { should contain_package('bogus-package').with_ensure('latest')}
  end
end
