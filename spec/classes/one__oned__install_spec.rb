require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::oned::install' do
  let (:facts) { {:osfamily => 'RedHat'} }
  let (:hiera_config) { hiera_config }
  context 'general' do
    let (:pre_condition) { 'include one' }
    #let (:params) {{ :use_params => 'true'}}
    it {should_not contain_package('rubygem-sinatra')}
    it {should_not contain_package('rubygem-builder')}
    it {should contain_package('sinatra').with_provider('gem')}
    it {should contain_package('builder').with_provider('gem')}
  end
  context 'with rpm instead of gems' do
    let (:pre_condition) { 'include one' }
    let (:params) {{ :use_gems => false}}
    it {should contain_package('rubygem-sinatra')}
    it {should contain_package('rubygem-builder')}
    it {should_not contain_package('sinatra').with_provider('gem')}
    it {should_not contain_package('builder').with_provider('gem')}
  end
end
