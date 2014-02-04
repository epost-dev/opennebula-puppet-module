require 'spec_helper'
require 'rspec-puppet'
require 'hiera'
require 'facter'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::compute_node' do
    context 'with hiera config on RedHat' do
        let(:hiera_config) { hiera_config }
        let (:facts) { {
            :osfamily => 'RedHat'
        } }
        context 'as compute node' do
            hiera = Hiera.new(:config => hiera_config)
            sshpubkey = hiera.lookup('one::head::ssh_pub_key', nil, nil)
            it { should contain_package('opennebula-node-kvm') }
            it { should contain_package('qemu-kvm') }
            it { should contain_package('libvirt') }
            it { should contain_package('bridge-utils') }
            it { should contain_package('vconfig') }
            it { should contain_package('sudo') }
            it { should contain_package('python-virtinst') }
            it { should contain_group('oneadmin') }
            it { should contain_user('oneadmin') }
            it { should contain_file('/etc/libvirt/libvirtd.conf') }
            it { should contain_file('/etc/sysconfig/libvirtd') }
            it { should contain_file('/var/lib/one/.ssh/authorized_keys').with_content(/#{sshpubkey}/m) }
            it { should contain_file('/etc/sudoers.d/10_oneadmin') }
            # imaginator checks
            it { should contain_file('/var/lib/one/.virtinst').with_ensure('directory') }
            it { should contain_file('/var/lib/one/.libvirt').with_ensure('directory') }
            it { should contain_file('/var/lib/libvirt/boot').with_owner('oneadmin') }
            it { should contain_file('/var/lib/libvirt/boot').with_group('oneadmin') }
            it { should contain_file('/var/lib/libvirt/boot').with_mode('0771') }
            it { should contain_file('/var/lib/one/bin').with_ensure('directory') }
            it { should contain_file('/var/lib/one/bin/imaginator').with_source('puppet:///modules/one/imaginator') }
            it { should contain_file('/var/lib/one/etc').with_ensure('directory') }
            it { should contain_file('/var/lib/one/etc/kickstart.d').with_ensure('directory') }
            # check if there ist content in the kickstart files
            it { should contain_file('/var/lib/one/etc/kickstart.d/foo.ks').with_content(/context/m) }
            it { should contain_file('/var/lib/one/etc/kickstart.d/rnr.ks').with_content(/context/m) }
        end
    end
    context 'with hiera config on Debian' do
        let(:hiera_config) { hiera_config }
        let (:facts) { {
            :osfamily => 'Debian'
        } }
        context 'as compute node' do
            hiera = Hiera.new(:config => hiera_config)
            sshpubkey = hiera.lookup('one::head::ssh_pub_key', nil, nil)
            it { should contain_package('opennebula-node') }
            it { should contain_package('qemu-kvm') }
            it { should contain_package('libvirt-bin') }
            it { should contain_package('bridge-utils') }
            it { should contain_package('sudo') }
            it { should contain_package('virtinst') }
            it { should contain_group('oneadmin') }
            it { should contain_user('oneadmin') }
            it { should contain_file('/etc/libvirt/libvirtd.conf') }
            it { should contain_file('/etc/default/libvirt-bin') }
            it { should contain_file('/var/lib/one/.ssh/authorized_keys').with_content(/#{sshpubkey}/m) }
            it { should contain_file('/etc/sudoers.d/10_oneadmin') }
            # imaginator checks
            it { should contain_file('/var/lib/one/.virtinst').with_ensure('directory') }
            it { should contain_file('/var/lib/one/.libvirt').with_ensure('directory') }
            it { should contain_file('/var/lib/libvirt/boot').with_owner('oneadmin') }
            it { should contain_file('/var/lib/libvirt/boot').with_group('oneadmin') }
            it { should contain_file('/var/lib/libvirt/boot').with_mode('0771') }
            it { should contain_file('/var/lib/one/bin').with_ensure('directory') }
            it { should contain_file('/var/lib/one/bin/imaginator').with_source('puppet:///modules/one/imaginator') }
            it { should contain_file('/var/lib/one/etc').with_ensure('directory') }
            it { should contain_file('/var/lib/one/etc/kickstart.d').with_ensure('directory') }
            # check if there ist content in the kickstart files
            it { should contain_file('/var/lib/one/etc/kickstart.d/foo.ks').with_content(/context/m) }
            it { should contain_file('/var/lib/one/etc/kickstart.d/rnr.ks').with_content(/context/m) }
        end
    end
end
