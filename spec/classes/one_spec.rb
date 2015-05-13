require 'spec_helper'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one', :type => :class do
  OS_FACTS.each do |f|
    context "On #{f[:operatingsystem]} #{f[:operatingsystemmajrelease]}" do
      let(:facts) { f }
      it { should contain_class('one') }
    end
  end
end