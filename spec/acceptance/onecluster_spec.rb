require 'spec_helper_acceptance'

describe 'onecluster type' do

  describe 'when creating a cluster' do
    it 'should idempotently run' do
      pending 'Need fix'
      pp = <<-EOS
        class { 'one':
          oned => true,
        } ->
        onecluster { 'new_cluster': }
        ->
        onecluster { 'new_cluster2': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when adding a host to a cluster' do
    it 'should idempotently run' do
      pending 'Need fix'
      pp =<<-EOS
      onehost { 'new_host':
        im_mad => 'kvm',
        vm_mad => 'kvm',
        vn_mad => 'dummy',
      } ->
      onecluster { 'new_cluster':
        hosts => 'new_host',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when adding an array of hosts to a cluster' do
    it 'should idempotently run' do
      pending 'Need fix'
      pp =<<-EOS
      onehost { 'new_host':
        im_mad => 'kvm',
        vm_mad => 'kvm',
        vn_mad => 'dummy',
      } ->
      onehost { 'new_host2':
        im_mad => 'kvm',
        vm_mad => 'kvm',
        vn_mad => 'dummy',
      } ->
      onecluster { 'new_cluster':
        hosts => ['new_host', 'new_host2'],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a cluster' do
    it 'should idempotently run' do
      pp =<<-EOS
      onecluster { 'new_cluster2':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
