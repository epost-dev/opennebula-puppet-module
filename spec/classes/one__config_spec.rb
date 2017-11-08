require 'spec_helper'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::config', :type => :class do
  OS_FACTS.each do |f|
    context "On #{f[:operatingsystem]} #{f[:operatingsystemmajrelease]}" do
      let(:facts) { f }
      context 'general' do
        let(:params) { {
        } }
        it { should contain_file('/var/lib/one') \
                    .with_ensure('directory') \
                    .with_owner('oneadmin') \
                    .with_group('oneadmin') \
                    .with_mode('0750')
        }
      end
    end
  end
end
