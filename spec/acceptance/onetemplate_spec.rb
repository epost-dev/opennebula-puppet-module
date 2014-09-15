require 'spec_helper_acceptance'

describe 'onetemplate type' do

  describe 'when creating a template' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { 'one':
          oned => true,
        } ->
        onetemplate { 'new_template':
          disks  => 'foo',
          nics   => 'bar',
          memory => 512,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a template' do
    it 'should idempotently run' do
      pp =<<-EOS
      onetemplate { 'new_template':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
