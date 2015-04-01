require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::oned::sunstone' do
  let (:facts) { {:osfamily => 'RedHat'} }
  let (:hiera_config) { hiera_config }
  let (:pre_condition) { 'include one' }
  context 'general' do
    let (:params) { {:ldap => false} }
    it { should contain_class('one::prerequisites') }
    it { should contain_class('one::oned::sunstone') }
    it { should contain_class('one::oned::sunstone::install') }
    it { should contain_class('one::oned::sunstone::config') }
    it { should contain_class('one::oned::sunstone::service') }
    it { should_not contain_class('one::oned::sunstone::ldap') }
  end
  context 'with ldap enabled' do
    let (:params) { {:ldap => true} }
    it { should contain_class('one::oned::sunstone::ldap') }
  end
end
