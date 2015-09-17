require 'spec_helper_acceptance'

describe 'onecluster type' do
  before :all do
    pp = <<-EOS
    class { 'one':
      oned => true,
    }
    onehost { 'host01':
      im_mad => 'dummy',
      vm_mad => 'dummy',
      vn_mad => 'dummy',
      status => 'disabled',
    }

    onehost { 'host02':
      im_mad => 'dummy',
      vm_mad => 'dummy',
      vn_mad => 'dummy',
      status => 'disabled',
    }

    onevnet { 'vnet1':
      ensure          => present,
      bridge          => 'basebr0',
      phydev          => 'br0',
      dnsservers      => ['8.8.8.8', '4.4.4.4'],
      gateway         => '10.0.2.1',
      vlanid          => '1550',
      netmask         => '255.255.0.0',
      network_address => '10.0.2.0',
    }

    onevnet { 'vnet2':
      ensure          => present,
      bridge          => 'basebr0',
      phydev          => 'br0',
      dnsservers      => ['8.8.8.8', '4.4.4.4'],
      gateway         => '10.0.2.1',
      vlanid          => '1550',
      netmask         => '255.255.0.0',
      network_address => '10.0.2.0',
    }

    EOS
    apply_manifest(pp, :catch_failures => true)
    #apply_manifest(pp, :catch_changes => true) # FIXME - Hosts can't run idempotently
  end

  after :all do
    pp = <<-EOS
    onehost { ['host01', 'host02']:
      ensure => absent,
    }

    onevnet { ['vnet1', 'vnet2']:
      ensure => absent,
    }

    onedatastore { ['system', 'default', 'files']:
      ensure => absent,
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  describe 'when creating a cluster' do
    it 'should idempotently run' do
      pp = <<-EOS
      onecluster { 'production':
        ensure => present,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when adding a host to a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
        hosts => 'host01',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when adding a datastore to a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
        datastores => 'system',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when adding a vnet to a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
        vnets => 'vnet1',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when adding an array of hosts to a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
        hosts => ['host01', 'host02'],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when adding an array of datastores to a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
        datastores => ['system','default','files'],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when adding an array of vnets to a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
        vnets => ['vnet1', 'vnet2'],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when removing a host from a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
        hosts => 'host01',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when removing a datastore from a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
        datastores => 'default',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when removing a vnet from a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
         vnets => 'vnet1',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when removing all vnets from a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
         vnets => [],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'production':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
