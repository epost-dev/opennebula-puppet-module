#!/usr/bin/env rspec

require 'spec_helper'

provider_class = Puppet::Type.type(:onedatastore).provider(:onedatastore)
describe provider_class do
  let(:resource ) {
    Puppet::Type::Onedatastore.new({
      :name => 'new_datastore',
    })
  }

  let(:provider) {
    @provider = provider_class.new(@resource)
  }

  it 'should exist' do
    @provider
  end
end
