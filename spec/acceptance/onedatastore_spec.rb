require 'spec_helper_acceptance'

describe 'onedatastore type' do
  before :all do
    pp = <<-EOS
    class { 'one':
      oned => true,
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  describe 'when creating a System datastore' do
    it 'should idempotently run' do
      pp = <<-EOS
      onedatastore { 'nfs_ds':
        tm_mad   => 'shared',
        type     => 'system_ds',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a File datastore' do
    it 'work without errors' do
      pp = <<-EOS
      onedatastore { 'kernels':
        ds_mad    => 'fs',
        safe_dirs => '/var/tmp/files',
        tm_mad    => 'ssh',
        type      => 'file_ds',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
  end

  describe 'when creating a Filesystem datastore' do
    it 'should idempotently run' do
      pp = <<-EOS
      onedatastore { 'production':
        ds_mad => 'fs',
        tm_mad => 'shared',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a VMFS datastore' do
    it 'should idempotently run' do
      pp = <<-EOS
      onedatastore { 'vmfs_ds':
        ds_mad => 'vmfs',
        tm_mad => 'vmfs',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a LVM datastore' do
    it 'should idempotently run' do
      pp = <<-EOS
      onedatastore { 'lvm_ds':
        ds_mad => 'fs_lvm',
        tm_mad => 'fs_lvm',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a Ceph datastore' do
    it 'should idempotently run' do
      pp = <<-EOS
      onedatastore { 'ceph_ds':
        ds_mad      => 'ceph',
        tm_mad      => 'ceph',
        driver      => 'raw',
        ceph_host   => 'cephhost',
        ceph_user   => 'cephuser',
        ceph_secret => 'cephsecret',
        pool_name   => 'cephpoolname',
        disk_type   => 'rbd',
        bridge_list => 'host1 host2 host3'
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a System datastore' do
    it 'should idempotently run' do
      pp =<<-EOS
      onedatastore { 'nfs_ds':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a Files datastore' do
    it 'should idempotently run' do
      pp =<<-EOS
      onedatastore { 'kernels':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a Filesystem datastore' do
    it 'should idempotently run' do
      pp =<<-EOS
      onedatastore { 'production':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a VMFS datastore' do
    it 'should idempotently run' do
      pp =<<-EOS
      onedatastore { 'vmfs_ds':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a LVM datastore' do
    it 'should idempotently run' do
      pp =<<-EOS
      onedatastore { 'lvm_ds':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a Ceph datastore' do
    it 'should idempotently run' do
      pp =<<-EOS
      onedatastore { 'ceph_ds':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when assigning a Datastore to a Cluster' do
    it 'should work with no errors' do
      pp = <<-EOS
      onedatastore { 'ds1':
        tm_mad   => 'shared',
        type     => 'system_ds',
      } ->

      onehost { 'host01':
        im_mad => 'kvm',
        vm_mad => 'kvm',
        vn_mad => 'dummy',
      } ->

      onevnet { 'vnet1':
          ensure          => present,
          bridge          => 'basebr0',
          phydev          => 'br0',
          dnsservers      => ['8.8.8.8', '4.4.4.4'],
          gateway         => '10.0.2.1',
          vlanid          => '1550',
          netmask         => '255.255.0.0',
          network_address => '10.0.2.0',
      } ->

      onecluster { 'production':
          ensure     => present,
          hosts      => 'host01',
          vnets      => 'vnet1',
          datastores => 'ds1',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
  end

end
