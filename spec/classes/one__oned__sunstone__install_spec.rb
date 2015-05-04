require 'spec_helper'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::oned::sunstone::install', :type => :class do
  OS_FACTS.each do |f|
    context "On #{f[:operatingsystem]} #{f[:operatingsystemmajrelease]}" do
      let(:facts) { f }
      let (:hiera_config) { hiera_config }
      let (:params) { {:oned_sunstone_packages => 'bogus-package'} }
      context 'general' do
        it { should contain_class('one::oned::sunstone::install') }
        it { should contain_package('bogus-package').with_ensure('latest') }
      end
    end
  end
end
