require 'spec_helper'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one', :type => :class do
  context 'with default params as implicit hiera lookup' do
    let (:facts) { {
            :osfamily => 'RedHat',
            :operatingsystemmajrelease => '7'
    } }
    it { should contain_class('one') }
    it { should_not contain_file('/etc/one/oned.conf').with_content(/^DB = \[ backend = \"sqlite\"/) }
    it { should_not contain_class('one::oned') }
  end
  let(:hiera_config) { hiera_config }
  OS_FACTS.each do |f|
    context "On #{f[:operatingsystem]} #{f[:operatingsystemmajrelease]}" do
      let(:facts) { f }
      context 'with hiera config' do
        let(:params) { {:oned => true} }
        hiera = Hiera.new(:config => hiera_config)
        configdir = '/etc/one'
        onehome = '/var/lib/one'
        oned_config = "#{configdir}/oned.conf"
        context 'with one module' do
          it { should contain_class('one') }
          it { should contain_class('one::prerequisites') }
          it { should contain_class('one::install') }
          it { should contain_class('one::config') }
          it { should contain_class('one::service') }
          it { should contain_package('dbus') }
          it { should contain_file(onehome).with_ensure('directory').with_owner('oneadmin') }
          it { should contain_file('/usr/share/one').with_ensure('directory') }
          it { should contain_file("#{onehome}/.ssh").with_ensure('directory') }
          it { should contain_file("#{onehome}/.ssh/config").with_ensure('file') }
          if (f[:osfamily] == 'Debian') or (f[:osfamily] == 'RedHat' and f[:operatingsystemmajrelease].to_i < 7)
            it { should contain_file('/sbin/brctl').with_ensure('link') }
          end
          it { should contain_file('/etc/libvirt/qemu.conf').with_ensure('file') }
          it { should contain_file('/etc/sudoers.d/20_imaginator').with_ensure('file') }
          it { should contain_file('/etc/udev/rules.d/80-kvm.rules').with_ensure('file') }
          if f[:osfamily] == 'Redhat'
            it { should contain_service('messagebus').with_ensure('running') }
          elsif f[:osfamily] == 'Debian'
            it { should contain_service('dbus').with_ensure('running') }
          end
          context 'as compute_node' do
            let(:params) { {
                :oned => false,
                :node => true,
            } }
            networkconfig = hiera.lookup('one::node::kickstart::network', nil, nil)
            sshpubkey = hiera.lookup('one::head::ssh_pub_key', nil, nil)
            it { should contain_class('one::compute_node') }
            it { should contain_class('one::compute_node::install') }
            it { should contain_class('one::compute_node::config') }
            it { should contain_class('one::compute_node::service') }
            it { should contain_one__compute_node__add_kickstart('foo') }
            it { should contain_one__compute_node__add_kickstart('rnr') }
            it { should contain_one__compute_node__add_preseed('does') }
            if f[:osfamily] == 'RedHat'
              it { should contain_package('opennebula-node-kvm') }
            elsif f[:osfamily] == 'Debian'
              it { should contain_package('opennebula-node') }
            end

            if f[:osfamily] == 'RedHat' and f[:operatingsystemmajrelease].to_i < 7
              it { should contain_package('python-virtinst') }
            elsif f[:osfamily] == 'Debian'
              it { should contain_package('virtinst') }
            end
            it { should contain_group('oneadmin') }
            it { should contain_user('oneadmin') }
            it { should contain_file('/etc/libvirt/libvirtd.conf').with_ensure('file') }
            if f[:osfamily] == 'RedHat'
              it { should contain_file('/etc/sysconfig/libvirtd').with_ensure('file') }
            elsif f[:osfamily] == 'Debian'
              it { should contain_file('/etc/default/libvirt-bin').with_ensure('file') }
            end
            it { should contain_file("#{onehome}/.ssh/authorized_keys").with_ensure('file').with_content(/#{sshpubkey}/m) }
            it { should contain_file('/etc/sudoers.d/10_oneadmin').with_ensure('file') }

            if f[:osfamily] == 'RedHat'
              it { should contain_service('libvirtd').with_ensure('running') }
            elsif f[:osfamily] == 'Debian'
              it { should contain_service('libvirt-bin').with_ensure('running') }
            end
            if f[:osfamily] == 'RedHat'
              it { should contain_service('ksm').with_ensure('running') }
              it { should contain_service('ksmtuned').with_ensure('stopped') }
            end
            context 'with imaginator' do
              it { should contain_file("#{onehome}/.virtinst").with_ensure('directory') }
              it { should contain_file("#{onehome}/.libvirt").with_ensure('directory') }
              it { should contain_file('/var/lib/libvirt/boot').with_owner('oneadmin').with_group('oneadmin').with_mode('0771') }
              it { should contain_file("#{onehome}/bin").with_ensure('directory') }
              it { should contain_file("#{onehome}/bin/imaginator").with_source('puppet:///modules/one/imaginator') }
              it { should contain_file("#{onehome}/etc").with_ensure('directory') }
              it { should contain_file("#{onehome}/etc/kickstart.d").with_ensure('directory') }
              it { should contain_file("#{onehome}/etc/preseed.d").with_ensure('directory') }
              context 'with kickstart for RedHat' do
                it { should contain_file("#{onehome}/etc/kickstart.d/foo.ks").with_content(/context/m) }
                it { should contain_file("#{onehome}/etc/kickstart.d/foo.ks").with_content(/device\s*=\s*#{networkconfig['device']}/m) }
                it { should contain_file("#{onehome}/etc/kickstart.d/rnr.ks").with_content(/context/m) }
                it { should contain_file("#{onehome}/etc/kickstart.d/rnr.ks").with_content(/device\s*=\s*#{networkconfig['device']}/m) }
                it { should contain_file("#{onehome}/etc/kickstart.d/rnr.ks").with_content(/part \/foo --fstype=ext4 --size=10000/) }
                it { should contain_file("#{onehome}/etc/kickstart.d/rnr.ks").with_content(/repo --name="puppet" --baseurl=http:\/\/yum-repo.example.com\/puppet\//) }
                it { should contain_file("#{onehome}/etc/kickstart.d/rnr.ks").with_content(/repo --name="one" --baseurl=http:/) }
              end
              context 'with preseed for Debian' do
                it { should contain_file("#{onehome}/etc/preseed.d/does.cfg").with({
                                                                                       'content' => /ftp.us.debian.org/,
                                                                                       'owner' => 'oneadmin',
                                                                                       'group' => 'oneadmin',
                                                                                   }) }
              end
            end
          end
          context 'as oned' do
            let(:params) { {
                :oned => true,
                :node => false,
            } }
            sshprivkey = hiera.lookup('one::head::ssh_priv_key', nil, nil)
            sshpubkey = hiera.lookup('one::head::ssh_pub_key', nil, nil)
            it { should contain_class('one::oned') }
            it { should contain_class('one::oned::install') }
            it { should contain_class('one::oned::config') }
            it { should contain_class('one::oned::service') }
            it { should contain_package('opennebula') }
            if f[:osfamily] == 'RedHat'
              it { should contain_package('opennebula-server') }
              it { should contain_package('opennebula-ruby') }
            elsif f[:osfamily] == 'Debian'
              it { should contain_package('opennebula-tools') }
              it { should contain_package('ruby-opennebula') }
            end
            it { should contain_file("#{onehome}/.ssh/id_dsa").with_content(sshprivkey) }
            it { should contain_file("#{onehome}/.ssh/id_dsa.pub").with_content(sshpubkey) }
            it { should contain_file("#{onehome}/.ssh/authorized_keys").with_content(sshpubkey) }
            context 'with sqlite backend' do
              it { should contain_file(oned_config).with_content(/^DB = \[ backend = \"sqlite\"/) }
            end
            context 'with mysql backend' do
              let(:params) { {
                  :oned => true,
                  :backend => 'mysql'
              } }
              it { should contain_file(oned_config).with_content(/^DB = \[ backend = \"mysql\"/) }
              it { should contain_file(hiera.lookup('one::oned::backup::script_path', nil, nil)).with_content(/mysqldump/m) }
              it { should contain_cron('one_db_backup').with({
                                                                 'command' => hiera.lookup('one::oned::backup::script_path', nil, nil),
                                                                 'user' => hiera.lookup('one::oned::backup::db_user', nil, nil),
                                                                 'target' => hiera.lookup('one::oned::backup::db_user', nil, nil),
                                                                 'minute' => hiera.lookup('one::oned::backup::intervall', nil, nil),
                                                             }) }
              it { should contain_file(hiera.lookup('one::oned::backup::dir', nil, nil)).with_ensure('directory') }
            end
            context 'with wrong backend' do
              let(:params) { {
                  :oned => true,
                  :backend => 'foobar'
              } }
              it { expect { should contain_class('one::oned') }.to raise_error(Puppet::Error) }
            end
            context 'with xmlrpc tuning' do
              it { should contain_file('/etc/one/oned.conf').with_content(/MAX_CONN           = 5000/) }
            end
            context 'with hookscripts configured in oned.conf' do
              expected_vm_hook=%q{
            VM_HOOK = \[
              name      = "dnsupdate",
              on        = "CREATE",
              command   = "\/usr\/share\/one\/hooks\/dnsupdate\.sh",
              arguments = "\$TEMPLATE",
              remote    = "no" \]
            VM_HOOK = \[
              name      = "dnsupdate_custom",
              on        = "CUSTOM",
              state     = "PENDING",
              lcm_state = "LCM_INIT",
              command   = "\/usr\/share\/one\/hooks\/dnsupdate\.sh",
              arguments = "\$TEMPLATE",
              remote    = "no" \]
          }
              expected_host_hook=%q{
            HOST_HOOK = \[
              name      = "error",
              on        = "ERROR",
              command   = "ft\/host_error.rb",
              arguments = "\$ID -r",
              remote    = "no" \]
          }
              # Check for correct template replacement but ignore whitspaces and stuff.
              # Hint for editing: with %q{} only escaping of doublequote is not needed.
              expected_vm_hook=expected_vm_hook.gsub(/\s+/, '\\s+')
              expected_host_hook=expected_host_hook.gsub(/\s+/, '\\s+')
              it { should contain_file(oned_config).with_content(/^#{expected_vm_hook}/m) }
              it { should contain_file(oned_config).with_content(/^#{expected_host_hook}/m) }
            end
            context 'with default hook scripts rolled out' do
              it { should contain_file('/usr/share/one/hooks').with_source('puppet:///modules/one/hookscripts') }
              it { should_not contain_file('/usr/share/one/hooks/tests').with_source('puppet:///modules/one/hookscripts/tests') }
            end
            context 'with hook scripts package defined' do
              it { should contain_package('hook_vms') }
              it { should contain_package('hook_hosts') }
            end
            context 'with oneflow' do
              let(:params) { {
                  :oneflow => true
              } }
              it { should contain_class('one::oned::oneflow') }
              it { should contain_class('one::oned::oneflow::install') }
              it { should contain_class('one::oned::oneflow::config') }
              it { should contain_class('one::oned::oneflow::service') }
              it { should contain_package('opennebula-flow') }
              if f[:osfamily] == 'RedHat'
                it { should contain_package('rubygem-treetop') }
                it { should contain_package('rubygem-polyglot') }
              elsif f[:osfamily] == 'Debian'
                it { should contain_package('ruby-treetop') }
                it { should contain_package('ruby-polyglot') }
              end
              it { should contain_service('opennebula-flow').with_ensure('running') }
            end
            context 'with onegate' do
              let(:params) { {
                  :onegate => true
              } }
              it { should contain_class('one::oned::onegate') }
              it { should contain_class('one::oned::onegate::install') }
              it { should contain_class('one::oned::onegate::config') }
              it { should contain_class('one::oned::onegate::service') }
              it { should contain_package('opennebula-gate') }
              if f[:osfamily] == 'RedHat'
                it { should contain_package('rubygem-parse-cron') }
              elsif f[:osfamily] == 'Debian'
                #it { should contain_package('parse-cron') }
              end
              it { should contain_service('opennebula-gate').with_ensure('running') }
            end
            context 'with sunstone' do
              let(:params) { {
                  :sunstone => true
              } }
              sunstone_config = "#{configdir}/sunstone-server.conf"
              it { should contain_class('one::oned::sunstone') }
              it { should contain_class('one::oned::sunstone::install') }
              it { should contain_class('one::oned::sunstone::config') }
              it { should contain_class('one::oned::sunstone::service') }
              it { should contain_package('opennebula-sunstone') }
              it { should contain_file("#{configdir}/sunstone-views.yaml").with_ensure('file') }
              it { should contain_file('/usr/lib/one/sunstone').with_ensure('directory') }
              it { should contain_file(sunstone_config) }
              it { should contain_service('opennebula-sunstone').with_ensure('running').with_require("Service[opennebula]") }
              context 'with passenger' do
                let(:params) { {
                    :sunstone => true,
                    :sunstone_passenger => true
                } }
                it { should contain_service('opennebula-sunstone').with_ensure('stopped').with_enable(false) }
              end
              context 'with ldap' do
                let(:params) { {
                    :oned => true,
                    :sunstone => true,
                    :ldap => true
                } }
                ldap_config = "#{configdir}/auth/ldap_auth.conf"
                it { should contain_class('one::oned::sunstone::ldap') }
                it { should contain_package('ruby-ldap') }
                if f[:osfamily] == 'RedHat'
                  it { should contain_package('rubygem-net-ldap') }
                elsif f[:osfamily] == 'Debian'
                  it { should contain_package('ruby-net-ldap') }
                end
                it { should contain_file(ldap_config).with_content(/secure_password/) }
                it { should contain_file(ldap_config).with_content(/\:encryption\: \:simple_tls/) }
                it { should contain_file('/var/lib/one/remotes/auth/default').with_ensure('link') }
              end
              context 'with wrong ldap' do
                let(:params) { {
                    :oned => true,
                    :sunstone => true,
                    :ldap => 'foobar'
                } }
                it { expect { should contain_class('one::oned') }.to raise_error(Puppet::Error) }
              end
              context 'with ha' do
                let(:params) { {
                    :oned => true,
                    :sunstone => true,
                    :ha_setup => true,
                } }
                it { should contain_service('opennebula').with_enable('false') }
                it { should contain_service('opennebula-sunstone').with_ensure('running') }
              end
            end
          end
        end
      end
    end
  end
end
