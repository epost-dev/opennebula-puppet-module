require 'spec_helper_acceptance'

describe 'onedatastore type' do

  describe 'when creating datastore' do
    it 'should idempotently run' do
      pending 'Need fix'
      pp = <<-EOS
        onedatastore { 'new_datastore':
	  type => 'images',
        }
        ->
        onedatastore { 'new_datastore2':
          type => 'system',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying a datastore' do
    it 'should idempotently run' do
      pp =<<-EOS
      onevm { 'new_datastore2':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
