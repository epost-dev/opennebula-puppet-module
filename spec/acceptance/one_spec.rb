require 'spec_helper_acceptance'

describe 'onevm class' do
  describe 'without parameters' do
    it 'should idempotently run' do
      pp = <<-EOS
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
