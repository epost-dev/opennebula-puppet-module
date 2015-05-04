require 'spec_helper'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::compute_node::config', :type => :class do
  OS_FACTS.each do |f|
    context "On #{f[:operatingsystem]} #{f[:operatingsystemmajrelease]}" do
      let(:facts) { f }
      let(:params) { {
          :debian_mirror_url => 'http://ftp.de.debian.org/debian',
          :preseed_data => {'does' => 'not_matter'},
          :libvirtd_cfg => '/etc/some/libvirt/config'
      } }
      it { should contain_class('one::compute_node::config') }
      it { should contain_file('/etc/libvirt/libvirtd.conf') }
      it { should contain_file('/etc/some/libvirt/config') }
      it { should contain_file('/etc/udev/rules.d/80-kvm.rules') }
      it { should contain_file('/etc/sudoers.d/10_oneadmin') }
      it { should contain_file('/etc/sudoers.d/20_imaginator') }
      if :osfamily == 'Debian'
        it { should contain_file('polkit-opennebula') \
            .with_path('/var/lib/polkit-1/localauthority/50-local.d/50-org.libvirt.unix.manage-opennebula.pkla')
        }
      elsif :osfamily == 'RedHat'
        it { should contain_file('polkit-opennebula') \
            .with_path('/etc/polkit-1/localauthority/50-local.d/50-org.libvirt.unix.manage-opennebula.pkla')
        }
      end
    end
  end
end
