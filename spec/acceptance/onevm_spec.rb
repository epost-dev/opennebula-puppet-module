require 'spec_helper_acceptance'

describe 'onevm type' do
  before :all do
    pp = <<-EOS
    class { 'one':
      oned => true,
    }
    onetemplate { 'test-vm':
      # Capacity
      cpu    => 1,
      memory => 128,

      # OS
      os     => {
        kernel     => '/vmlinuz',
        initrd     => '/initrd.img',
        root       => 'sda1',
        kernel_cmd => 'ro xencons=tty console=tty1',
      },

      # Features
      features => {
        acpi        => true,
        pae         => true,
      },

      # Disks
      disks  => [
        { image => 'Data',},
        { image => 'Experiments',},
        { type => 'fs', size => 4096, format => 'ext3',},
        { type => 'swap', size => 1024, },
      ],

      # Network
      nics   => [
        { network => 'Blue', bridge => 'vbr0', },
        { network => 'Red', bridge => 'vbr1', },
      ],

      # I/O Devices
      graphics => {
        type   => 'vnc',
        listen => '0.0.0.0',
        port   => 5,
      },
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  describe 'when creating vm' do
    it 'should idempotently run' do
      pending 'Need fix'
      pp = <<-EOS
        onevm { 'new_vm':
          template => 'test-vm',
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
