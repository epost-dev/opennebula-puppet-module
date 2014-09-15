require 'spec_helper_acceptance'

describe 'onevm type' do

  describe 'when creating vm' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'one':
          oned => true,
        } ->
        oneimage { 'new_image':
          source => '/foo/bar.img',
          size   => '50',
        }
        ->
        onevnet { 'new_vnet':
          user            => 'oneadmin',
          password        => 'oneadmin',
          bridge          => 'vbr0',
          network_address => '192.168.0.0',
        } 
        ->
        onetemplate { 'new_template':
          nics   => 'bar',
          memory => 512,
          cpu    => 1,
	  disks  => 'new_image',
        }
        ->
        onevm { 'new_vm':
          template => 'new_template',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a vm' do
    it 'should idempotently run' do
      pp =<<-EOS
      onevm { 'new_vm':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
