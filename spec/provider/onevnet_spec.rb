#!/usr/bin/env rspec

require 'spec_helper'

provider_class = Puppet::Type.type(:onevnet).provider(:onevnet)
describe provider_class do
  let(:resource ) {
    Puppet::Type::Onevnet.new({
      :name => 'new_vnet',
      :username => 'oneadmin',
      :password => 'oneadmin',
    })
  }

  let(:provider) {
    @provider = provider_class.new(@resource)
  }

  it 'should exist' do
    @provider
  end

  context 'when checking if resource exists' do
      it 'should return true if resource exists' do
          pending('needs test to verify existance')
      end
      it 'should return false if reosurce does not exists' do
          pending('needs test to verify absence')
      end
  end
  context 'when creating' do
      it 'should create tempfile with proper values' do
          pending('needs tests to verify creation')
      end
  end
  context 'when deleting' do
      it 'should run onevnet delete <name>' do
        pending('needs test to verify removal')
      end
  end
  context 'when updating' do
      pending('update needs all tests')
  end

end
