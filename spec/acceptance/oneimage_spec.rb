require 'spec_helper_acceptance'

describe 'oneimage type' do
  before :all do
    pp = <<-EOS
    class { 'one':
      oned => true,
    }
    file { ['/home/one_user', '/home/one_user/images']:
      ensure => directory,
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  describe 'when creating an OS image' do
    it 'should idempotently run' do
      skip
      pp = <<-EOS
        exec { '/usr/bin/qemu-img create /home/one_user/images/ubuntu_desktop.img 1G':
          creates => '/home/one_user/images/ubuntu_desktop.img',
        }
        ->
        oneimage { 'Ubuntu':
          datastore   => 'default',
          description => 'Ubuntu 10.04 desktop for students.',
          path        => '/home/one_user/images/ubuntu_desktop.img',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a CDROM image' do
    it 'should idempotently run' do
      skip
      pp = <<-EOS
        exec { '/usr/bin/mkisofs -o /home/one_user/images/matlab.iso /tmp':
          creates => '/home/one_user/images/matlab.iso',
        }
        ->
        oneimage { 'MATLAB install CD':
          datastore   => 'default',
          description => 'Contains the MATLAB installation files. Mount it to install MATLAB on new OS images.',
          path        => '/home/one_user/images/matlab.iso',
          type        => 'cdrom',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a DATABLOCK image' do
    it 'should idempotently run' do
      skip
      pending 'This example from the doc does not actually work!'
      pp = <<-EOS
        oneimage { 'Experiment results':
          datastore   => 'default',
          description => 'Storage for my Thesis experiments.',
          size        => '3.08',
          fstype      => 'ext3',
          type        => 'datablock',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying an OS image' do
    it 'should idempotently run' do
      pp =<<-EOS
      oneimage { 'Ubuntu':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a CDROM image' do
    it 'should idempotently run' do
      pp =<<-EOS
      oneimage { 'MATLAB install CD':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a DATABLOCK image' do
    it 'should idempotently run' do
      pp =<<-EOS
      oneimage { 'Experiment results':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
