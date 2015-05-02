require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::compute_node', :type => :class do
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
      let (:pre_condition) { 'include one' }
      context 'with classes' do
        it { should contain_class('one::compute_node') }
        it { should contain_class('one::prerequisites') }
        it { should contain_class('one::install') }
        it { should contain_class('one::config') }
        it { should contain_class('one::compute_node::install') }
        it { should contain_class('one::compute_node::config') }
        it { should contain_class('one::compute_node::service') }
        it { should contain_class('one::service') }
      end
      context 'with puppetdb enabled' do
        let(:params) {{
            :puppetdb => true,
        }}
        # cannot test exported resource
      end
      context 'with puppetdb disabled' do
        let(:params) {{
            :puppetdb => false,
        }}
        # cannot test exported resource
      end
    end
  end
end