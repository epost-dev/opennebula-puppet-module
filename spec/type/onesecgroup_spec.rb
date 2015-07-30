#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :onesecgroup
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
    @secgroup = res_type.new(:name => 'test')
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

  properties = [:description, :rules]

  properties.each do |property|
    it "should have a #{property} property" do
      described_class.attrclass(property).ancestors.should be_include(Puppet::Property)
    end

    it "should have documentation for its #{property} property" do
      described_class.attrclass(property).doc.should be_instance_of(String)
    end
  end

  it 'should have property :description' do
    @secgroup[:description] = 'This is a description.'
    @secgroup[:description].should == 'This is a description.'
  end

  it 'should have property :rules' do
    @secgroup[:rules] = [{'protocol' => 'ALL', 'rule_type' => 'OUTBOUND'}, {'protocol' => 'ALL', 'rule_type' => 'INBOUND'}]
    @secgroup[:rules].should == [{'protocol' => 'ALL', 'rule_type' => 'OUTBOUND'}, {'protocol' => 'ALL', 'rule_type' => 'INBOUND'}]
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
