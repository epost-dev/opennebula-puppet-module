#!/usr/bin/env rspec

require 'spec_helper'

provider_class = Puppet::Type.type(:onehost).provider(:onehost)
describe provider_class do
  let(:resource ) {
    Puppet::Type::Onehost.new({
      :name => 'new_cluster',
    })
  }

  let(:provider) {
    @provider = provider_class.new(@resource)
  }

  it 'should exist' do
    @provider
  end
end
