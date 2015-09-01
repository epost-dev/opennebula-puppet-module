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

  properties = [:type, :dm, :tm, :disktype, :driver, :cephhost, :cephuser,
                :cephsecret, :poolname, :bridgelist]
  properties.each do |property|
    it "should have a #{property} property" do
      described_class.attrclass(property).ancestors.should be_include(Puppet::Property)
    end

    it "should have documentation for its #{property} property" do
      described_class.attrclass(property).doc.should be_instance_of(String)
    end
  end

  it 'should have property :type' do
      @datastore[:type] = 'IMAGE_DS'
      @datastore[:type].should == :IMAGE_DS
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

  it 'should have property :driver' do
      @datastore[:driver] = 'qcow2'
      @datastore[:driver].should == 'qcow2'
  end

  it 'should have property :cephhost' do
      @datastore[:cephhost] = 'cephhost'
      @datastore[:cephhost].should == 'cephhost'
  end

  it 'should have property :cephuser' do
      @datastore[:cephuser] = 'cephuser'
      @datastore[:cephuser].should == 'cephuser'
  end

  it 'should have property :cephsecret' do
      @datastore[:cephsecret] = 'cephsecret'
      @datastore[:cephsecret].should == 'cephsecret'
  end

  it 'should have property :poolname' do
      @datastore[:poolname] = 'poolname'
      @datastore[:poolname].should == 'poolname'
  end

  it 'should have property :bridgelist' do
      @datastore[:bridgelist] = 'host1 host2 host3'
      @datastore[:bridgelist].should == 'host1 host2 host3'
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
