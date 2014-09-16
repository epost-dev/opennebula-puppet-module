require 'spec_helper_acceptance'

describe 'onevnet type' do

  describe 'when creating a ranged vnet' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'one':
          oned => true,
        }
        ->
        onevnet { 'ranged_vnet':
          type            => 'ranged',
          bridge          => 'vbr0',
          network_address => '192.168.0.0/24',
          network_start   => '192.168.0.3',
          #gateway         => '192.168.0.1', # create does not support it yet
          #dnsservers      => '192.168.0.1', # create does not support it yet
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a fixed vnet' do
    it 'should idempotently run' do
      pending "It looks like onevnet doesn't take the leases"
      pp = <<-EOS
        class { 'one':
          oned => true,
        }
        ->
        onevnet { 'fixed_vnet':
          type       => 'fixed',
          bridge     => 'vbr1',
          leases     => [
            '130.10.0.1',
            '130.10.0.2',
            '130.10.0.3',
            '130.10.0.4',
          ],
          #gateway    => '130.10.0.1', # create does not support it yet
          #dnsservers => '130.10.0.1', # create does not support it yet
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when updating a ranged vnet' do
    it 'should idempotently run' do
      pp =<<-EOS
        onevnet { 'ranged_vnet':
          type            => 'ranged',
          bridge          => 'vbr0',
          network_address => '192.168.0.0/24',
          network_start   => '192.168.0.3',
          gateway         => '192.168.0.1',
          dnsservers      => '192.168.0.1',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when updating a fixed vnet' do
    it 'should idempotently run' do
      pending "It looks like onevnet doesn't take the leases"
      pp =<<-EOS
        onevnet { 'fixed_vnet':
          type       => 'fixed',
          bridge     => 'vbr1',
          leases     => [
            '130.10.0.1',
            '130.10.0.2',
            '130.10.0.3',
            '130.10.0.4',
            '130.10.0.5',
          ],
          gateway    => '130.10.0.1',
          dnsservers => '130.10.0.1',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a ranged vnet' do
    it 'should idempotently run' do
      pp =<<-EOS
      onevnet { 'ranged_vnet':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a fixed vnet' do
    it 'should idempotently run' do
      pp =<<-EOS
      onevnet { 'fixed_vnet':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
