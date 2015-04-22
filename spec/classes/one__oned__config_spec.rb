require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::oned::config' do
  let (:facts) { {:osfamily => 'RedHat'} }
  let (:hiera_config) { hiera_config }
  let (:pre_condition) { 'include one' }
  context 'general' do
    it { should contain_class('one::oned::config') }
    it { should contain_file('/etc/one/oned.conf') \
                    .with_ensure('file' )\
                    .with_owner('root') \
                    .with_mode('0640')
    }
    it { should contain_file('/usr/share/one/hooks') \
                    .with_ensure('directory') \
                    .with_mode('0750')
    }
    it { should contain_file('/usr/share/one').with_ensure('directory') }
  end
  context 'with mysql backend' do
    let (:params) { {
        :backend => 'mysql',
        :backup_script_path => '/var/lib/one/bin/one_db_backup.sh',
        :backup_dir => '/srv/backup'
    } }
    it { should contain_file('/srv/backup') }
    it { should contain_file('/var/lib/one/bin/one_db_backup.sh') }
    it { should contain_cron('one_db_backup')}

  end
end
