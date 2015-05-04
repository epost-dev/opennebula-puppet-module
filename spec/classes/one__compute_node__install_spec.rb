require 'spec_helper'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::compute_node::install', :type => :class do
  OS_FACTS.each do |f|
    context "On #{f[:operatingsystem]} #{f[:operatingsystemmajrelease]}" do
      let(:facts) { f }
      let(:params) { {
          :node_packages => 'bogus_package'
      } }
      it { should contain_class('one::compute_node::install') }
      it { should contain_package('bogus_package').with_ensure('latest') }
    end
  end
end
