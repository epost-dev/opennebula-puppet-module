require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

configdir = '/etc/one'
oned_config = "#{configdir}/oned.conf"
sunstone_config = "#{configdir}/sunstone-server.conf"
ldap_config = "#{configdir}/auth/ldap_auth.conf"
hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one' do
    context 'with hiera config on RedHat' do
        let(:hiera_config) { hiera_config }
        let (:facts) { {
            :osfamily => 'RedHat'
        } }
        context 'as compute node' do
            hiera = Hiera.new(:config => hiera_config)
            sshprivkey = hiera.lookup('one::head::ssh_priv_key', nil, nil)
            sshpubkey = hiera.lookup('one::head::ssh_pub_key', nil, nil)
            it { should contain_class('one') }
            it { should contain_class('one::compute_node') }
            it { should contain_package('opennebula-node-kvm') }
            it { should contain_package('qemu-kvm') }
            it { should contain_package('libvirt') }
            it { should contain_package('bridge-utils') }
            it { should contain_package('vconfig') }
            it { should contain_package('sudo') }
            it { should contain_group('oneadmin') }
            it { should contain_user('oneadmin') }
            it { should contain_file('/etc/libvirt/libvirtd.conf') }
            it { should contain_file('/etc/sysconfig/libvirtd') }
            it { should contain_file('/var/lib/one/.ssh/id_dsa')\
                .with_content(sshprivkey)
            }
            it { should contain_file('/var/lib/one/.ssh/id_dsa.pub')\
                .with_content(sshpubkey)
            }
        end # fin context 'as compute node'

        context 'as compute node with imaginator' do
          it { should contain_file('/var/lib/one/bin').with_ensure('directory')}
          it { should contain_file('/var/lib/one/.virtinst').with_ensure('directory')}
          it { should contain_file('/var/lib/one/.libvirt').with_ensure('directory')}
          it { should contain_file('/var/lib/one/bin/imaginator').with_source('puppet:///modules/one/imaginator')}
        end # fin context 'as compute node with imaginator'

        context 'as mgmt node' do
            let(:hiera_config) { hiera_config }
            let (:facts) { {
                :osfamily => 'RedHat'
            } }
            context 'with sqlite' do
                let(:params) { { 
                    :oned => true,
                    :backend => 'sqlite' 
                } }
                hiera = Hiera.new(:config => hiera_config)
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
                it { should contain_service('opennebula-sunstone').with_ensure('running') }
            end # fin context 'as mgmt node | with sunstone'
            context 'with sunstone and ldap' do
                let(:params) {{
                    :oned => true,
                    :sunstone => true,
                    :ldap => true
                }}
                hiera = Hiera.new(:config => hiera_config)
                it { should contain_class('one') }
                it { should contain_class('one::oned') }
                it { should contain_class('one::oned::sunstone') }
                it { should contain_class('one::oned::sunstone::ldap') }
                it { should contain_file(ldap_config).with_content(/secure_password/) }
                it { should contain_service('opennebula-sunstone').with_ensure('running') }
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
                it { should contain_service('opennebula-sunstone').with_ensure('running') }
            end # fin context 'as mgmt node | with sunstone and ha'
        end # fin context 'as mgmt node'
    end # fin context "with hiera config on RedHat"
    context "with hiera config on Debian" do
        let(:hiera_config) { hiera_config }
        let (:facts) { {
            :osfamily => 'Debian'
        } }
        context 'as compute node' do
            hiera = Hiera.new(:config => hiera_config)
            sshprivkey = hiera.lookup("one::head::ssh_priv_key", nil, nil)
            sshpubkey = hiera.lookup("one::head::ssh_pub_key", nil, nil)
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
                .with_content(sshprivkey)
            }
            it { should contain_file("/var/lib/one/.ssh/id_dsa.pub")\
                .with_content(sshpubkey)
            }
        end # fin context 'as compute node'
        context 'as mgmt node' do
            let(:hiera_config) { hiera_config }
            let (:facts) { {
                :osfamily => 'Debian'
            } }
            context 'with sqlite' do
                let(:params) { { 
                    :oned => true,
                    :backend => 'sqlite' 
                } }
                hiera = Hiera.new(:config => hiera_config)
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
                it { should contain_service('opennebula-sunstone').with_ensure('running') }
            end # fin context 'as mgmt node | with sunstone'
            context 'with sunstone and ldap' do
                let(:params) {{
                    :oned => true,
                    :sunstone => true,
                    :ldap => true
                }}
                hiera = Hiera.new(:config => hiera_config)
                it { should contain_class('one') }
                it { should contain_class('one::oned') }
                it { should contain_class('one::oned::sunstone') }
                it { should contain_class('one::oned::sunstone::ldap') }
                it { should contain_file(ldap_config).with_content(/secure_password/) }
                it { should contain_service('opennebula-sunstone').with_ensure('running') }
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
                it { should contain_service('opennebula-sunstone').with_ensure('running') }
            end # fin context 'as mgmt node | with sunstone and ha'
        end # fin context 'as mgmt node'
    end # fin context "with hiera config on Debian"
end # fin describe 'one'
