require 'spec_helper_acceptance'

describe 'oneimage type' do

  describe 'when creating an image' do
    it 'should idempotently run' do
      pending 'Need fix'
      pp = <<-EOS
        class { 'one':
          oned => true,
        } ->
        oneimage { 'new_image':
          source => '/foo/bar.img',
          size   => '50',
        } ->
        oneimage { 'new_image2':
          source => '/foo/baz.img',
          size   => '100',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

  describe 'when destroying an image' do
    it 'should idempotently run' do
      pp =<<-EOS
      oneimage { 'new_image2':
       ensure => absent,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end

end
