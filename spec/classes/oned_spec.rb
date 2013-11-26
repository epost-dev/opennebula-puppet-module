require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

configdir = '/etc/one'
oned_config = "#{configdir}/oned.conf"
sunstone_config = "#{configdir}/sunstone-server.conf"

describe 'one::oned' do
    include_context "hieradata"
    context "with hiera config on RedHat" do
        let (:facts) { {
            :osfamily => 'RedHat'
        } }
        context 'as mgmt node with sqlite' do
            let(:params) { { 
                :backend => 'sqlite',
                :ldap => false
            } }
            it { should contain_package("dbus") }
            it { should contain_package("opennebula") }
            it { should contain_package("opennebula-server") }
            it { should contain_package("opennebula-ruby") }
            it { should contain_file(oned_config).with_content(/^DB = \[ backend = \"sqlite\"/) }
            it { should contain_file("/var/lib/one").with({
                'owner' => 'oneadmin' 
            })}
        end
        context 'as mgmt node with mysql' do
            let(:params) {{ 
                :backend => 'mysql',
                :ldap => false
            }}
            it { should contain_package("dbus") }
            it { should contain_package("opennebula") }
            it { should contain_package("opennebula-server") }
            it { should contain_package("opennebula-ruby") }
            it { should contain_file(oned_config).with_content(/^DB = \[ backend = \"mysql\"/) }
            it { should contain_file("/var/lib/one").with({
                'owner' => 'oneadmin' 
            })}
        end
    end
    context "with hiera config on Debian" do
        let (:facts) { {
            :osfamily => 'Debian'
        } }
        context 'as mgmt node with sqlite' do
            let(:params) { { 
                :backend => 'sqlite',
                :ldap => false
            } }
            it { should contain_package("dbus") }
            it { should contain_package("opennebula") }
            it { should contain_package("ruby-opennebula") }
            it { should contain_file(oned_config).with_content(/^DB = \[ backend = \"sqlite\"/) }
            it { should contain_file("/var/lib/one").with({
                'owner' => 'oneadmin' 
            })}
        end
        context 'as mgmt node with mysql' do
            let(:params) {{ 
                :backend => 'mysql',
                :ldap => false
            }}
            it { should contain_package("dbus") }
            it { should contain_package("opennebula") }
            it { should contain_package("ruby-opennebula") }
            it { should contain_file(oned_config).with_content(/^DB = \[ backend = \"mysql\"/) }
            it { should contain_file("/var/lib/one").with({
                'owner' => 'oneadmin' 
            })}
        end
    end

end
