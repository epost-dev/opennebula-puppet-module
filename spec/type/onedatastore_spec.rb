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

  properties = [:tm_mad, :type, :safe_dirs, :ds_mad, :disk_type, :driver, :bridge_list,
                :ceph_host, :ceph_user, :ceph_secret, :pool_name, :staging_dir, :base_path,
                :cluster]

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

  it 'should have property :ds_mad' do
    @datastore[:ds_mad] = 'baz'
    @datastore[:ds_mad].should == 'baz'
  end

  it 'should have property :tm_MAD' do
    @datastore[:tm_mad] = 'foobar'
    @datastore[:tm_mad].should == 'foobar'
  end

  it 'should have property :disk_type' do
    @datastore[:disk_type] = 'file'
    @datastore[:disk_type].should == 'file'
  end

  it 'should have property :driver' do
    @datastore[:driver] = 'qcow2'
    @datastore[:driver].should == 'qcow2'
  end

  it 'should have property :ceph_host' do
    @datastore[:ceph_host] = 'cephhost'
    @datastore[:ceph_host].should == 'cephhost'
  end

  it 'should have property :ceph_user' do
    @datastore[:ceph_user] = 'cephuser'
    @datastore[:ceph_user].should == 'cephuser'
  end

  it 'should have property :ceph_secret' do
    @datastore[:ceph_secret] = 'cephsecret'
    @datastore[:ceph_secret].should == 'cephsecret'
  end

  it 'should have property :poolname' do
    @datastore[:pool_name] = 'poolname'
    @datastore[:pool_name].should == 'poolname'
  end

  it 'should have property :bridgelist' do
    @datastore[:bridge_list] = 'host1 host2 host3'
    @datastore[:bridge_list].should == 'host1 host2 host3'
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
