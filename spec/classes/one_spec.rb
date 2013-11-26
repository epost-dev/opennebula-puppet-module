require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

configdir = '/etc/one'
oned_config = "#{configdir}/oned.conf"
sunstone_config = "#{configdir}/sunstone-server.conf"
ldap_config = "#{configdir}/auth/ldap_auth.conf"

describe 'one' do
    include_context "hieradata"
    context "with hiera config on RedHat" do
        let (:facts) { {
            :osfamily => 'RedHat'
        } }
        context 'as compute node' do
            it { should contain_class('one') }
            it { should contain_class('one::compute_node') }
            it { should contain_package("opennebula-node-kvm") }
            it { should contain_package("qemu-kvm") }
            it { should contain_package("libvirt") }
            it { should contain_package("bridge-utils") }
            it { should contain_package("vconfig") }
            it { should contain_package("sudo") }
            it { should contain_group("oneadmin") }
            it { should contain_user("oneadmin") }
            it { should contain_file("/etc/libvirt/libvirtd.conf") }
            it { should contain_file("/etc/sysconfig/libvirtd") }
            it { should contain_file("/var/lib/one/.ssh/id_dsa")\
                .with_content('ssh-dsa priv key')
            }
            it { should contain_file("/var/lib/one/.ssh/id_dsa.pub")\
                .with_content('ssh pub key')
            }
        end # fin context 'as compute node'
        context 'as mgmt node' do
            let (:facts) { {
                :osfamily => 'RedHat'
            } }
            context 'with sqlite' do
                let(:params) { { 
                    :oned => true,
                    :backend => 'sqlite' 
                } }
                it { should contain_class('one') }
                it { should contain_class('one::oned') }
                it { should contain_package("dbus") }
                it { should contain_package("opennebula") }
                it { should contain_package("opennebula-server") }
                it { should contain_package("opennebula-ruby") }
                it { should contain_file(oned_config).with_content(/^DB = \[ backend = \"sqlite\"/) }
                it { should contain_file("/var/lib/one").with({
                    'owner' => 'oneadmin'
                })}
            end # fin context 'as mgmt node | with sqlite'
            context 'with mysql' do
                let(:params) {{ 
                    :oned => true,
                    :backend => 'mysql' 
                }}
                it { should contain_class('one') }
                it { should contain_class('one::oned') }
                it { should contain_package("dbus") }
                it { should contain_package("opennebula") }
                it { should contain_package("opennebula-server") }
                it { should contain_package("opennebula-ruby") }
                it { should contain_file(oned_config).with_content(/^DB = \[ backend = \"mysql\"/) }
                it { should contain_file("/var/lib/one").with({
                    'owner' => 'oneadmin'
                })}
            end # fin context 'as mgmt node | with mysql'
            context 'with wrong backend' do
                let(:params) {{
                    :oned => true,
                    :backend => 'foobar'
                }}
                it { expect { should contain_class('one::oned') }.to raise_error(Puppet::Error) }
            end # fin context 'as mgmt node | with wrong backend'
            context 'with sunstone' do
                let(:params) {{
                    :oned => true,
                    :sunstone => true
                }}
                it { should contain_class('one') }
                it { should contain_class('one::oned') }
                it { should contain_class('one::oned::sunstone') }
                it { should contain_package("opennebula-sunstone") }
                it { should contain_file(sunstone_config) }
            end # fin context 'as mgmt node | with sunstone'
            context 'with sunstone and ldap' do
                let(:params) {{
                    :oned => true,
                    :sunstone => true,
                    :ldap => true
                }}
                it { should contain_class('one') }
                it { should contain_class('one::oned') }
                it { should contain_class('one::oned::sunstone') }
                it { should contain_class('one::oned::sunstone::ldap') }
                it { should contain_file(ldap_config).with_content(/secure_password/) }
            end # fin context 'as mgmt node | with sunstone and ldap'
            context 'with sunstone and ldap set wrong' do
                let(:params) {{
                    :oned => true,
                    :sunstone => true,
                    :ldap => 'foobar'
                }}
                it { expect { should contain_class('one::oned') }.to raise_error(Puppet::Error) }
            end # fin context 'as mgmt node | with sunstone and ldap set wrong'
            context 'with sunstone and ha' do
                let(:params) {{
                    :oned => true,
                    :sunstone => true,
                    :ha_setup => true,
                }}
                it { should contain_service('opennebula').with_enable('false') }
            end # fin context 'as mgmt node | with sunstone and ha'
        end # fin context 'as mgmt node'
    end # fin context "with hiera config on RedHat"
    context "with hiera config on Debian" do
        let (:facts) { {
            :osfamily => 'Debian'
        } }
        context 'as compute node' do
            it { should contain_class('one') }
            it { should contain_class('one::compute_node') }
            it { should contain_package("opennebula-node") }
            it { should contain_package("qemu-kvm") }
            it { should contain_package("libvirt-bin") }
            it { should contain_package("bridge-utils") }
            it { should contain_package("sudo") }
            it { should contain_group("oneadmin") }
            it { should contain_user("oneadmin") }
            it { should contain_file("/etc/libvirt/libvirtd.conf") }
            it { should contain_file("/etc/default/libvirt-bin") }
            it { should contain_file("/var/lib/one/.ssh/id_dsa")\
                .with_content('ssh-dsa priv key')
            }
            it { should contain_file("/var/lib/one/.ssh/id_dsa.pub")\
                .with_content('ssh pub key')
            }
        end # fin context 'as compute node'
        context 'as mgmt node' do
            let (:facts) { {
                :osfamily => 'Debian'
            } }
            context 'with sqlite' do
                let(:params) { { 
                    :oned => true,
                    :backend => 'sqlite' 
                } }
                it { should contain_class('one') }
                it { should contain_class('one::oned') }
                it { should contain_package("dbus") }
                it { should contain_package("opennebula") }
                it { should contain_package("ruby-opennebula") }
                it { should contain_file(oned_config).with_content(/^DB = \[ backend = \"sqlite\"/) }
                it { should contain_file("/var/lib/one").with({
                    'owner' => 'oneadmin'
                })}
            end # fin context 'as mgmt node | with sqlite'
            context 'with mysql' do
                let(:params) {{ 
                    :oned => true,
                    :backend => 'mysql' 
                }}
                it { should contain_class('one') }
                it { should contain_class('one::oned') }
                it { should contain_package("dbus") }
                it { should contain_package("opennebula") }
                it { should contain_package("ruby-opennebula") }
                it { should contain_file(oned_config).with_content(/^DB = \[ backend = \"mysql\"/) }
                it { should contain_file("/var/lib/one").with({
                    'owner' => 'oneadmin'
                })}
            end # fin context 'as mgmt node | with mysql'
            context 'with wrong backend' do
                let(:params) {{
                    :oned => true,
                    :backend => 'foobar'
                }}
                it { expect { should contain_class('one::oned') }.to raise_error(Puppet::Error) }
            end # fin context 'as mgmt node | with wrong backend'
            context 'with sunstone' do
                let(:params) {{
                    :oned => true,
                    :sunstone => true
                }}
                it { should contain_class('one') }
                it { should contain_class('one::oned') }
                it { should contain_class('one::oned::sunstone') }
                it { should contain_package("opennebula-sunstone") }
                it { should contain_file(sunstone_config) }
            end # fin context 'as mgmt node | with sunstone'
            context 'with sunstone and ldap' do
                let(:params) {{
                    :oned => true,
                    :sunstone => true,
                    :ldap => true
                }}
                it { should contain_class('one') }
                it { should contain_class('one::oned') }
                it { should contain_class('one::oned::sunstone') }
                it { should contain_class('one::oned::sunstone::ldap') }
                it { should contain_file(ldap_config).with_content(/secure_password/) }
            end # fin context 'as mgmt node | with sunstone and ldap'
            context 'with sunstone and ldap set wrong' do
                let(:params) {{
                    :oned => true,
                    :sunstone => true,
                    :ldap => 'foobar'
                }}
                it { expect { should contain_class('one::oned') }.to raise_error(Puppet::Error) }
            end # fin context 'as mgmt node | with sunstone and ldap set wrong'
            context 'with sunstone and ha' do
                let(:params) {{
                    :oned => true,
                    :sunstone => true,
                    :ha_setup => true,
                }}
                it { should contain_service('opennebula').with_enable('false') }
            end # fin context 'as mgmt node | with sunstone and ha'
        end # fin context 'as mgmt node'
    end # fin context "with hiera config on Debian"
end # fin describe 'one'
