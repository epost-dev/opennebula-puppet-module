#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :onevnet_addressrange
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
    @vnet = res_type.new(:name => 'test')
    @vnet4 = res_type.new(:name => 'test')
    @vnet6 = res_type.new(:name => 'test')
  end

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  parameters = []

  parameters.each do |params|
      it "should have a #{params} parameter" do
          expect(described_class.attrtype(params)).to eq :param
      end
  end

  properties = [:onevnet_name, :ar_id, :protocol, :ip_start, :ip_size, :mac, :globalprefix, :ulaprefix]

  properties.each do |property|
    it "should have a #{property} property" do
      described_class.attrclass(property).ancestors.should be_include(Puppet::Property)
    end

    it "should have documentation for its #{property} property" do
      described_class.attrclass(property).doc.should be_instance_of(String)
    end
  end

  it 'should have property :onevnet_name' do
      @vnet4[:onevnet_name] = 'testnet'
      @vnet4[:onevnet_name].should == 'testnet'
  end

  it 'should have property :protocol' do
      @vnet4[:protocol] = 'ip4'
      @vnet4[:protocol].should == :ip4
  end

  it 'should have property :ip_start' do
      @vnet6[:ip_start] = '10.0.2.3'
      @vnet6[:ip_start].should == '10.0.2.3'
  end

  it 'should have property :globalprefix' do
      @vnet6[:globalprefix] = '64'
      @vnet6[:globalprefix].should == '64'
  end

  it 'should have property :mac' do
      @vnet6[:mac] = 'aa:bb:cc:dd:ee:ff'
      @vnet6[:mac].should == 'aa:bb:cc:dd:ee:ff'
  end

  it 'should have property :ip_size' do
      @vnet6[:ip_size] = '33'
      @vnet6[:ip_size].should == '33'
  end

  parameter_tests = {
    :name => {
      :valid => ["test", "foo"],
      :default => "test",
      :invalid => ["0./fouzb&$", "&fr5"],
    },
  }
  it_should_behave_like "a puppet type", parameter_tests, res_type_name

  it 'should fail when passing wrong paramter to mac' do
      #expect {
      #    @vnet[:mac] = 'foo'
      #}.to raise_error(Puppet::Error)
      skip("needs parameter validation")
  end

  it 'should fail when passing ipv4 and not providing ip' do
      #expect {
      #    @vnet4[:ip] = :undef
      #}.to raise_error(Puppet::Error)
      skip("needs parameter validation")
  end

  it 'should fail when passing ipv4 and not providing size' do
      #expect {
      #    @vnet4[:ip_size] = :undef
      #}.to raise_error(Puppet::Error)
      skip("needs parameter validation")
  end

end
