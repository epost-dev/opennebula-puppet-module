require 'spec_helper'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::install', :type => :class do
  OS_FACTS.each do |f|
    context "On #{f[:operatingsystem]} #{f[:operatingsystemmajrelease]}" do
      let(:facts) { f }
      context 'general' do
        let(:params) { {
            :dbus_pkg => 'dbus',
        } }
        it { should contain_class('one::install') }
        it { should contain_package('dbus') \
                    .with_ensure('latest')
        }
      end
      context 'with gemrc and proxy not set' do
        let(:params) { {
            :http_proxy => '',
            :dbus_pkg => 'dbus',
        } }
        no_proxy = %Q{---\nhttp_proxy: \n}
        it { should contain_file('/etc/gemrc').with_content(no_proxy) }
      end
      context 'with gemrc and proxy set' do
        let(:params) { {
            :http_proxy => 'http://some.crap.com:8080',
            :dbus_pkg => 'dbus',
        } }
        proxy = %Q{---\nhttp_proxy: http://some.crap.com:8080\n}
        it { should contain_file('/etc/gemrc').with_content(proxy) }
      end
    end
  end
end

