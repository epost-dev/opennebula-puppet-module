require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::oned::sunstone::ldap' do
  let (:facts) { {:osfamily => 'RedHat'} }
  let (:hiera_config) { hiera_config }
  let (:params) { {:oned_sunstone_ldap_pkg => 'bogus-ldap-package'} }
  context 'general' do
    it { should contain_class('one::oned::sunstone::ldap') }
    it { should contain_package('bogus-ldap-package').with_ensure('latest') }
    it { should contain_file('/var/lib/one/remotes/auth/default') \
          .with_ensure('link') \
          .with_target('/var/lib/one/remotes/auth/ldap')
    }
    ### move all variables in ldap_auth.conf to parameters of this class?
    it { should contain_file('/etc/one/auth/ldap_auth.conf') \
          .with_ensure('file') \
          .with_mode('0640') \
          .with_notify('Service[opennebula]')
    }
  end
end
