require 'spec_helper'



configdir = '/etc/one'
oned_config = "#{configdir}/oned.conf"
sunstone_config = "#{configdir}/sunstone-server.conf"

describe 'one::compute_node' do
    include_context "hieradata"
    context "with hiera config on RedHat" do
        let (:facts) { {
            :osfamily => 'RedHat'
        } }
        context 'as compute node' do
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
        end
    end
    context "with hiera config on Debian" do
        let (:facts) { {
            :osfamily => 'Debian'
        } }
        context 'as compute node' do
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
        end
    end
end
