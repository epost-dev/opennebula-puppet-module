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
        tm   => 'shared',
        type => 'system_ds',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a Files datastore' do
    it 'should idempotently run' do
      skip
      pp = <<-EOS
      onedatastore { 'kernels':
        dm        => 'fs',
        safe_dirs => '/var/tmp/files',
        tm        => 'ssh',
        type      => 'file_ds',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a Filesystem datastore' do
    it 'should idempotently run' do
      pp = <<-EOS
      onedatastore { 'production':
        dm   => 'fs',
        tm   => 'shared',
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
        dm => 'vmfs',
        tm => 'vmfs',
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
        dm => 'fs_lvm',
        tm => 'fs_lvm',
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
        dm         => 'ceph',
        tm         => 'ceph',
        driver     => 'raw',
        cephhost   => 'cephhost',
        cephuser   => 'cephuser',
        cephsecret => 'cephsecret',
        poolname  => 'cephpoolname',
        disktype   => 'rbd',
        bridgelist => 'host1 host2 host3'
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

end
