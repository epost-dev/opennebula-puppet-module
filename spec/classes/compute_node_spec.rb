require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

configdir = '/etc/one'
oned_config = "#{configdir}/oned.conf"
sunstone_config = "#{configdir}/sunstone-server.conf"
hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::compute_node' do
    context "with hiera config on RedHat" do
        let(:hiera_config) { hiera_config }
        let (:facts) { {
            :osfamily => 'RedHat'
        } }
        context 'as compute node' do
            hiera = Hiera.new(:config => hiera_config)
            sshprivkey = hiera.lookup("one::head::ssh_priv_key", nil, nil)
            sshpubkey = hiera.lookup("one::head::ssh_pub_key", nil, nil)
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
                .with_content(sshprivkey)
            }
            it { should contain_file("/var/lib/one/.ssh/id_dsa.pub")\
                .with_content(sshpubkey)
            }
        end
    end
    context "with hiera config on Debian" do
        let(:hiera_config) { hiera_config }
        let (:facts) { {
            :osfamily => 'Debian'
        } }
        context 'as compute node' do
            hiera = Hiera.new(:config => hiera_config)
            sshprivkey = hiera.lookup("one::head::ssh_priv_key", nil, nil)
            sshpubkey = hiera.lookup("one::head::ssh_pub_key", nil, nil)
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
        end
    end
end
