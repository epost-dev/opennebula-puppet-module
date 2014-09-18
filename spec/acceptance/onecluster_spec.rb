require 'spec_helper_acceptance'

describe 'onecluster type' do
  before :all do
    pp = <<-EOS
    class { 'one':
      oned => true,
    }
    ->
    onehost { ['host01', 'host02']:
      ensure  => present, # FIXME: ensurable should default to :present...
    }
    ->
    onevnet { ['Blue LAN', 'Red LAN']:
      type       => 'fixed',
      bridge     => 'vbr1',
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  after :all do
    pp = <<-EOS
    onehost { ['host01', 'host02']:
      ensure => absent,
    }
    onevnet { ['Blue LAN', 'Red LAN']:
      ensure => absent,
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  describe 'when creating a cluster' do
    it 'should idempotently run' do
      pp = <<-EOS
      onecluster { 'production': }
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
        vnets => 'Blue LAN',
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
        vnets => ['Blue LAN', 'Red LAN'],
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
        hosts => 'host02',
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
        vnets => ['Red LAN'],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a cluster' do
    it 'should idempotently run' do
      pending 'Fail in acceptance tests only???'
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
