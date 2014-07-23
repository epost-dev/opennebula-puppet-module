#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :onevnet
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
    @vnet4 = res_type.new(:name => 'test', :protocol => 'ipv4')
    @vnet6 = res_type.new(:name => 'test', :protocol => 'ipv6')
  end

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  parameters = [:user, :password, :protocol]

  parameters.each do |params|
      it "should have a #{params} parameter" do
          expect(described_class.attrtype(params)).to eq :param
      end
  end

  properties = [:network_address, :network_mask, :siteprefix, :globalprefix, :dnsservers, :gateway, :type, :network_start, :network_end, :macstart, :network_size, :leases, :model, :bridge, :vlanid, :context]

  properties.each do |property|
    it "should have a #{property} property" do
      described_class.attrclass(property).ancestors.should be_include(Puppet::Property)
    end

    it "should have documentation for its #{property} property" do
      described_class.attrclass(property).doc.should be_instance_of(String)
    end
  end

  it 'should have property :protocol' do
      @vnet[:protocol] = 'ipv4'
      @vnet[:protocol].should == :ipv4
  end

  it 'should have property :network_address' do
      @vnet4[:network_address] = '10.0.2.0'
      @vnet4[:network_address].should == '10.0.2.0'
  end

  it 'should have property :network_mask' do
      @vnet4[:network_mask] = '255.255.255.0'
      @vnet4[:network_mask].should == '255.255.255.0'
  end

  it 'should have property :siteprefix' do
      @vnet6[:siteprefix] = '::1'
      @vnet6[:siteprefix].should == '::1'
  end

  it 'should have property :globalprefix' do
      @vnet6[:globalprefix] = '64'
      @vnet6[:globalprefix].should == '64'
  end

  it 'should have property :dnsservers' do
      @vnet[:dnsservers] = ['8.8.8.8','4.4.4.4']
      @vnet[:dnsservers].should == ['8.8.8.8','4.4.4.4']
  end

  it 'should have property :gateway' do
      @vnet[:gateway] = '10.0.2.1'
      @vnet[:gateway].should == '10.0.2.1'
  end

  it 'should have property :type' do
      @vnet[:type] = 'fixed'
      @vnet[:type].should == :fixed
  end

  it 'should have property :network_start' do
      @vnet4[:network_start] = '10.0.2.22'
      @vnet4[:network_start].should == '10.0.2.22'
  end

  it 'should have property :network_end' do
      @vnet4[:network_end] = '10.0.2.44'
      @vnet4[:network_end].should == '10.0.2.44'
  end

  it 'should have property :macstart' do
      @vnet6[:macstart] = 'aa:bb:cc:dd:ee:ff'
      @vnet6[:macstart].should == 'aa:bb:cc:dd:ee:ff'
  end

  it 'should have property :network_size' do
      @vnet6[:network_size] = '33'
      @vnet6[:network_size].should == '33'
  end

  it 'should have property :leases' do
      @vnet[:leases] = [{ 'foo' => '1' , 'bar' => '2' }]
      @vnet[:leases].should == [{ 'foo' => '1' , 'bar' => '2' }]
  end

  it 'should have property :model' do
      @vnet[:model] = 'vlan'
      @vnet[:model].should == :vlan
  end

  it 'should have property :bridge' do
      @vnet[:bridge] = 'br0'
      @vnet[:bridge].should == 'br0'
  end

  it 'should have property :context' do
      @vnet[:context] = 'foo'
      @vnet[:context].should == 'foo'
  end

  parameter_tests = {
    :name => {
      :valid => ["test", "foo"],
      :default => "test",
      :invalid => ["0./fouzb&$", "&fr5"],
    },
  }
  it_should_behave_like "a puppet type", parameter_tests, res_type_name

  it 'should fail when passing wrong parameter to protocol' do
      expect {
          @vnet[:protocol] = 'foo'
      }.to raise_error(Puppet::Error)
  end

  it 'should fail when passing wrong parameter to type' do
      expect {
          @vnet[:type] = 'foo'
      }.to raise_error(Puppet::Error)
  end

  it 'should fail when passing wrong paramter to macstart' do
      expect {
          @vnet[:macstart] = 'foo'
      }.to raise_error(Puppet::Error)
  end

  it 'should fail when passing wrong argument to model' do
      expect {
          @vnet[:model] = 'foo'
      }.to raise_error(Puppet::Error)
  end

  it 'should fail when passing ipv4 and not providing network_address' do
      expect {
          @vnet4[:network_address] = :undef
      }.to raise_error(Puppet::Error)
  end

  it 'should fail when passing ipv4 and not providing network_mask' do
      expect {
          @vnet4[:network_mask] = :undef
      }.to raise_error(Puppet::Error)
  end

  it 'should fail when passing ipv4 and not providing gateway' do
      expect {
          @vnet4[:gateway] = :undef
      }.to raise_error(Puppet::Error)
  end

  it 'should fail when passing ipv4 and not providing DNS server' do
      expect {
          @vnet4[:dnsservers] = :undef
      }.to raise_error(Puppet::Error)
  end

  it 'should fail when passing ipv6 and using network_address' do
      expect {
          @vnet6[:network_address] = '10.0.2.0'
      }.to raise_error(Puppet::Error)
  end

  it 'should fail when passing ipv6 and using network_mask' do
      expect {
          @vnet6[:network_mask] = '255.255.255.0'
      }.to raise_error(Puppet::Error)
  end
end
