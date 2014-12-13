#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :onetemplate
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
      @template = res_type.new(:name => 'test')
  end

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  it 'should have property :memory' do
      @template[:memory] = '4096'
      @template[:memory].should == '4096'
  end

  it 'should have property :cpu' do
      @template[:cpu] = '0.5'
      @template[:cpu].should == '0.5'
  end

  it 'should have property :vcpu' do
      @template[:vcpu] = '8'
      @template[:vcpu].should == '8'
  end

  it 'should have property :os_kernel' do
      @template[:os_kernel] = 'vmlinuz'
      @template[:os_kernel].should == 'vmlinuz'
  end

  it 'should have property :os_initrd' do
      @template[:os_initrd] = 'initrd'
      @template[:os_initrd].should == 'initrd'
  end

  it 'should have property :os_arch' do
      @template[:os_arch] = 'x86_64'
      @template[:os_arch].should == 'x86_64'
  end

  it 'should have property :os_root' do
      @template[:os_root] = 'sda1'
      @template[:os_root].should == 'sda1'
  end

  it 'should have property :os_kernel_cmd' do
      @template[:os_kernel_cmd] = 'silent'
      @template[:os_kernel_cmd].should == 'silent'
  end

  it 'should have property :os_bootloader' do
      @template[:os_bootloader] = '/sbin/lilo'
      @template[:os_bootloader].should == '/sbin/lilo'
  end

  it 'should have property :os_boot' do
      @template[:os_boot] = 'hd'
      @template[:os_boot].should == 'hd'
  end

  it 'should have property :acpi' do
      @template[:acpi] = :true
      @template[:acpi].should == :true
  end

  it 'should have property :pae' do
      @template[:pae] = :true
      @template[:pae].should == :true
  end

  it 'should have property :pci_bridge' do
      @template[:pci_bridge] = '2'
      @template[:pci_bridge].should == '2'
  end

  it 'should have property :disks' do
      @template[:disks] = ['base', 'storage']
      @template[:disks].should == [{"image"=>"base"}, {"image"=>"storage"}]
  end

  it 'should have property :nics' do
      @template[:nics] = ['core', 'backup']
      @template[:nics].should == [{"network"=>"core"}, {"network"=>"backup"}]
  end

  it 'should have property :graphics_type' do
      @template[:graphics_type] = 'vnc'
      @template[:graphics_type].should == 'vnc'
  end

  it 'should have property :graphics_listen' do
      @template[:graphics_listen] = '10.0.2.3'
      @template[:graphics_listen].should == '10.0.2.3'
  end

  it 'should have property :graphics_port' do
      @template[:graphics_port] = '1234'
      @template[:graphics_port].should == '1234'
  end

  it 'should have property :graphics_passwd' do
      @template[:graphics_passwd] = 'foo'
      @template[:graphics_passwd].should == 'foo'
  end

  it 'should have property :graphics_keymap' do
      @template[:graphics_keymap] = 'de'
      @template[:graphics_keymap].should == 'de'
  end

  it 'should have property :context' do
      @template[:context] = 'foo'
      @template[:context].should == 'foo'
  end

  it 'should have property :context_ssh_pubkey' do
      @template[:context_ssh_pubkey] = 'bar'
      @template[:context_ssh_pubkey].should == 'bar'
  end

  it 'should have property :context_network' do
      @template[:context_network] = :true
      @template[:context_network].should == :true
  end

  it 'should have property :context_onegate' do
      @template[:context_onegate] = 'foo'
      @template[:context_onegate].should == 'foo'
  end

  it 'should have property :context_files' do
      @template[:context_files] = ['init.sh','user.sh']
      @template[:context_files].should == ['init.sh','user.sh']
  end

  it 'should have property :context_variables' do
      @template[:context_variables] = 'foo'
      @template[:context_variables].should == 'foo'
  end

  it 'should have property :context_placement_host' do
      @template[:context_placement_host] = 'host1'
      @template[:context_placement_host].should == 'host1'
  end

  it 'should have property :context_placement_cluster' do
      @template[:context_placement_cluster] = 'cluster1'
      @template[:context_placement_cluster].should == 'cluster1'
  end

  it 'should have property :context_policy' do
      @template[:context_policy] = 'loadaware'
      @template[:context_policy].should == 'loadaware'
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
