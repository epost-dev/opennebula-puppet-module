require 'spec_helper_acceptance'

describe 'onevnet type' do
  before :all do
    pp =<<-EOS
      class { 'one':
        oned => true,
      }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  describe 'when creating a fixed vnet' do
    it 'should idempotently run' do
      skip
      pp =<<-EOS
        onevnet { 'Blue LAN':
          type       => 'fixed',
          bridge     => 'vbr1',
          leases     => [
            '130.10.0.1',
            '130.10.0.2',
            '130.10.0.3',
            '130.10.0.4',
          ],
          gateway    => '130.10.0.1',
          dnsservers => '130.10.0.1',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      pending "It looks like onevnet doesn't take the leases"
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a ranged vnet' do
    it 'should idempotently run' do
      skip
      pp =<<-EOS
        onevnet { 'Red LAN':
          type            => 'ranged',
          bridge          => 'vbr0',
          network_address => '192.168.0.0',
          network_size    => 'C',
          gateway         => '192.168.0.1',
          dnsservers      => '192.168.0.1',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      pending "create does not support gateway and dnsservers yet"
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating an IPv6 Network' do
    it 'should idempotently run' do
      skip
      pp =<<-EOS
        onevnet { 'Red LAN 6':
          type         => 'ranged',
          bridge       => 'vbr0',
          macstart     => '02:00:c0:a8:00:01',
          network_size => 'C',
          siteprefix   => 'fd12:33a:df34:1a::',
          globalprefix => '2004:a128::',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      pending "onevnet create does not take macstart and network_size"
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when updating a fixed vnet' do
    it 'should idempotently run' do
      skip
      pp =<<-EOS
        onevnet { 'Blue LAN':
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
      pending "It looks like onevnet doesn't take the leases"
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when updating a ranged vnet' do
    it 'should idempotently run' do
      skip
      pp =<<-EOS
        onevnet { 'Red LAN':
          type            => 'ranged',
          bridge          => 'vbr0',
          network_address => '192.168.1.0',
          network_size    => 'C',
          gateway         => '192.168.1.1',
          dnsservers      => '192.168.1.1',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when updating an IPv6 Network' do
    it 'should idempotently run' do
      skip
      pp =<<-EOS
        onevnet { 'Red LAN 6':
          type         => 'ranged',
          bridge       => 'vbr0',
          macstart     => '03:00:c0:a8:00:01',
          network_size => 'C',
          siteprefix   => 'fd12:33a:df34:1a::',
          globalprefix => '2004:a128::',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when deleting a Network' do
    it 'should idempotently run' do
      skip
      pp =<<-EOS
        onevnet { 'Blue LAN':
          ensure => absent,
        }
        onevnet { 'Red LAN':
          ensure => absent,
        }
        onevnet { 'Red LAN 6':
          ensure => absent,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
