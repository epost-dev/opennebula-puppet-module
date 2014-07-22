#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :onedatastore
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
      @datastore = res_type.new(:name => 'test')
  end
  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  parameters = [:user, :password]
  parameters.each do |params|
      it "should have a #{params} parameter" do
          expect(described_class.attrtype(params)).to eq :param
      end
  end

  properties = [:preset, :cluster, :type, :dm, :tm, :disktype, :safedirs, :restricteddirs]
  properties.each do |property|
    it "should have a #{property} property" do
      described_class.attrclass(property).ancestors.should be_include(Puppet::Property)
    end

    it "should have documentation for its #{property} property" do
      described_class.attrclass(property).doc.should be_instance_of(String)
    end
  end

  it 'should have property :preset' do
      @datastore[:preset] = 'filesystem'
      @datastore[:preset].should == 'filesystem'
  end

  it 'should have property :cluster' do
      @datastore[:cluster] = 'foo'
      @datastore[:cluster].should == 'foo'
  end

  it 'should have property :type' do
      @datastore[:type] = 'bar'
      @datastore[:type].should == 'bar'
  end

  it 'should have property :dm' do
      @datastore[:dm] = 'baz'
      @datastore[:dm].should == 'baz'
  end

  it 'should have property :tm' do
      @datastore[:tm] = 'foobar'
      @datastore[:tm].should == 'foobar'
  end

  it 'should have property :disktype' do
      @datastore[:disktype] = 'file'
      @datastore[:disktype].should == 'file'
  end

  it 'should have property :safedirs' do
      @datastore[:safedirs] = ['/','/bin']
      @datastore[:safedirs].should == ['/','/bin']
  end

  it 'should have property :restrciteddirs' do
      @datastore[:restricteddirs] = ['/','/tmp']
      @datastore[:restricteddirs].should == ['/','/tmp']
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
