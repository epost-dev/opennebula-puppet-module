require 'spec_helper_acceptance'

describe 'onehost type' do

  describe 'when creating a onehost' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'one':
          oned => true,
        } ->
        onehost { 'new_host':
          im_mad => 'kvm',
          vm_mad => 'kvm',
          vn_mad => 'dummy',
        } 
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a onehost' do
    it 'should idempotently run' do
      pp =<<-EOS
      onehost { 'new_host':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
