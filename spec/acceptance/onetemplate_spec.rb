require 'spec_helper_acceptance'

describe 'onetemplate type' do
  before :all do
    pp = <<-EOS
    class { 'one':
      oned => true,
    }
    onetemplate { 'test-vm':
      ensure => absent,
    }
    EOS
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  describe 'when creating a template with deprecated properties' do
    it 'should idempotently run' do
      pp = <<-EOS
        onetemplate { 'test-vm':
          # Capacity
          cpu    => 1,
          memory => 128,

          # OS
          os_kernel     => '/vmlinuz',
          os_initrd     => '/initrd.img',
          os_root       => 'sda1',
          os_kernel_cmd => 'ro xencons=tty console=tty1',

          # Features
          acpi        => true,
          pae         => true,

          # Disks
          disks  => [ 'Data', 'Experiments', ],

          # Network
          nics   => [ 'Blue', 'Red', ],

          # I/O Devices
          graphics_type   => 'vnc',
          graphics_listen => '0.0.0.0',
          graphics_port   => 5,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a template' do
    it 'should idempotently run' do
      pp =<<-EOS
      onetemplate { 'test-vm':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when creating a template' do
    it 'should idempotently run' do
      pp = <<-EOS
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
  end

  describe 'when destroying a template' do
    it 'should idempotently run' do
      pp =<<-EOS
      onetemplate { 'test-vm':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
