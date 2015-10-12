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

    after(:each) do
      pp = <<-EOS
      onedatastore { 'nfs_ds':
        ensure    => absent,
        self_test => false,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    context "with default values" do
      it 'should idempotently run' do
        pp = <<-EOS
        onedatastore { 'nfs_ds':
          tm_mad    => 'shared',
          type      => 'system_ds',
          self_test => false,
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end
    end

    context "with custom values" do
      it 'should idempotently run' do
        pp = <<-EOS
        onedatastore { 'nfs_ds':
          ensure    => present,
          type      => 'system_ds',
          tm_mad    => 'shared',
          driver    => 'raw',
          disk_type => 'file',
          self_test => false,
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end
    end

    context "with custom basepath" do
      it 'should idempotently run' do
        pp = <<-EOS
        onedatastore { 'nfs_ds':
          ensure    => present,
          type      => 'system_ds',
          tm_mad    => 'shared',
          driver    => 'raw',
          disk_type => 'file',
          base_path => '/tmp',
          self_test => false,
        }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end
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
        self_test => false,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
  end

  describe 'when creating a Filesystem datastore' do
    it 'should idempotently run' do
      pp = <<-EOS
      onedatastore { 'production':
        ds_mad    => 'fs',
        tm_mad    => 'shared',
        self_test => false,
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
        ds_mad    => 'vmfs',
        tm_mad    => 'vmfs',
        self_test => false,
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
        ds_mad    => 'fs_lvm',
        tm_mad    => 'fs_lvm',
        self_test => false,
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
        bridge_list => 'host1 host2 host3',
        self_test   => false,
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
        ensure    => absent,
        self_test => false,
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
        ensure    => absent,
        self_test => false,
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
        ensure    => absent,
        self_test => false,
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
        ensure    => absent,
        self_test => false,
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
        ensure    => absent,
        self_test => false,
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
        ensure    => absent,
        self_test => false,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
