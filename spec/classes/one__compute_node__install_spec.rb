require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::compute_node::install', :type => :class do
  [
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
  ].each do |f|
    context "On #{f[:operatingsystem]} #{f[:operatingsystemmajrelease]}" do
      let(:facts) { f }
      let(:params) { {
          :node_packages => 'bogus_package'
      } }
      it { should contain_class('one::compute_node::install')}
      it { should contain_package('bogus_package').with_ensure('latest') }
    end
  end
end
