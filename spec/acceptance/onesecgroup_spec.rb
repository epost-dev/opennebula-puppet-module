require 'spec_helper_acceptance'

describe 'onesecgroup type' do
  before :all do
    pp =<<-EOS
      class { 'one':
        oned => true,
      }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  describe 'when creating secgroup' do
    it 'should idempotently run' do
      pp =<<-EOS
      onesecgroup { 'secgroup1':
        ensure      => present,
        description => 'Description.',
        rules       => [{'protocol' => 'ALL', 'rule_type' => 'OUTBOUND'}],
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
  end

  describe 'when updating a fixed secgroup' do
    it 'should idempotently run' do
      pp =<<-EOS
      onesecgroup { 'secgroup1':
        ensure      => present,
        description => 'Description.',
        rules       => [{'protocol' => 'ALL', 'rule_type' => 'OUTBOUND'}],
      }
      EOS

      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when deleting a Security Group' do
    it 'should idempotently run' do
      pp =<<-EOS
        onesecgroup { 'secgroup1':
          ensure => absent,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
end
