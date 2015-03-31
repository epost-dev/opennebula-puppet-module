require 'spec_helper_acceptance'

describe 'one class' do
  describe 'without parameters' do
    it 'should idempotently run' do
      pp = <<-EOS
        class { one: }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end
  end
  describe 'as ONE HEAD' do
    it 'set up ONE HEAD' do
      pp = <<-EOS
        class { one: oned => true }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe user('oneadmin') do
      it { should exist }
    end
    describe package('opennebula') do
      it { should be_installed }
    end
    describe service('opennebula') do
      it { should be_enabled }
      it { should be_running }
    end

    describe package('opennebula-sunstone') do
      it { should_not be_installed }
    end

    describe service('opennebula-sunstone') do
      it { should_not be_running }
    end
  end

  describe 'as ONE Head with Sunstone' do
    it 'installs Opennebula Head with sunstone' do
      pp = <<-EOS
        class { one: oned => true, sunstone => true, node => false}
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('opennebula-sunstone') do
      it { should be_installed }
    end

    describe service('opennebula-sunstone') do
      it { should be_enabled }
      it { should be_running }
    end

    it "should listen on port 9869" do
      result = shell( 'netstat -tulpn | grep 9869 | wc -l' )
      expect(result.stdout).to match(/1/)
    end
  end

  describe 'as ONE Node' do
    it 'set up ONE Node' do
      pp = <<-EOS
        class { one: node => true }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    if fact('osfamily') == 'RedHat'
      describe package('opennebula-node-kvm') do
        it { should be_installed }
      end
    end
  end
end
