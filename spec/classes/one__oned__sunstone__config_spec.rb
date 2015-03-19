require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::oned::sunstone::config' do
  let (:facts) { {:osfamily => 'RedHat'} }
  let (:hiera_config) { hiera_config }
  context 'general' do
    it { should contain_class('one::oned::sunstone::config') }
    it { should contain_file('/usr/lib/one/sunstone') \
        .with_ensure('directory') \
        .with_owner('oneadmin') \
        .with_group('oneadmin') \
        .with_recurse('true')
    }
    it { should contain_file('/etc/one/sunstone-views/admin.yaml') \
        .with_ensure('file') \
        .with_mode('0640') \
        .with_group('oneadmin') \
    }
  end
  context 'with sunstone listen ip set' do
    let (:params) { {:listen_ip => '1.2.3.4'} }
    it { should contain_file('/etc/one/sunstone-server.conf') \
        .with_content(/:host: 1.2.3.4/m)
    }
  end
  context 'with sunstone listen not ip set' do
    it { should contain_file('/etc/one/sunstone-server.conf') \
        .with_content(/:host: /m)
    }
  end
  context 'with support enabled' do
    let (:params) { {:enable_support => 'yes'} }

    expected_routes = ':routes:
    - oneflow
    - vcenter
    - support'

    it { should contain_file('/etc/one/sunstone-server.conf').with_content(/#{expected_routes}/m)
    }
  end
  context 'with support disabled' do
    let (:params) { {:enable_support => 'no'} }

    unexpected_routes ='
    - vcenter
    - support'

    it { should_not contain_file('/etc/one/sunstone-server.conf').with_content(/#{unexpected_routes}/m) }
  end
  context 'with marketplace enabled' do
    let (:params) { {:enable_marketplace => 'yes'} }
    it { should contain_file('/etc/one/sunstone-views.yaml') \
        .with_content(/- marketplace-tab/m)
    }
  end
  context 'with marketplace disabled' do
    let (:params) { {:enable_marketplace => 'no'} }
    it { should_not contain_file('/etc/one/sunstone-views.yaml') \
        .with_content(/- marketplace-tab/m)
    }
  end
end
