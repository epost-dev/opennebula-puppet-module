#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :oneimage
res_type = Puppet::Type.type(res_type_name)

describe res_type do
  let(:provider) {
    prov = stub 'provider'
    prov.stubs(:name).returns(res_type_name)
    prov
  }
  let(:res_type) {
    val = res_type
    val.stubs(:defaultprovider).returns provider
    val
  }
  let(:resource) {
    res_type.new({:name => 'test'})
  }

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  parameter_tests = {
    :name => {
      :valid => ["test", "foo"],
      :default => "test",
    },
  }
  it_should_behave_like "a puppet type", parameter_tests, res_type_name
end
