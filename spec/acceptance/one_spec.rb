require 'spec_helper_acceptance'

describe 'onevm class' do
  describe 'without parameters' do
    it 'should idempotently run' do
      pp = <<-EOS
        yumrepo {'epel':
          descr    => "Extra Packages for Enterprise Linux ${::operatingsystemmajrelease} - \\$basearch",
          baseurl  => "http://download.fedoraproject.org/pub/epel/${::operatingsystemmajrelease}/\\$basearch",
          enabled  => 1,
          gpgkey   => "http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}",
          gpgcheck => 1,
        }
        ->
        class { 'one': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
  describe 'with oned => true' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'one':
          oned => true,
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end
