require 'spec_helper_acceptance'

describe 'onevm class' do
  describe 'without parameters' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'one': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
  describe 'with oned => true' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'one':
          oned => true,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
