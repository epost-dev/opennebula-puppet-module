#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :onevm
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
#  let(:resource) {
#    res_type.new({:name => 'test'})
#  }
  before :each do
      @vm = res_type.new(:name => 'test')
  end

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  it 'should have property :template' do
      @vm[:template] = 'abc'
      @vm[:template].should == 'abc'
  end

  it 'should have property :amount' do
      @vm[:amount] = '2'
      @vm[:amount].should == '2'
  end

  parameter_tests = {
    :name => {
      :valid => ["test", "foo"],
      :default => "test",
      :invalid => ["0./fouzb&$", "&fr5"],
    },
  }
  it_should_behave_like "a puppet type", parameter_tests, res_type_name
end
