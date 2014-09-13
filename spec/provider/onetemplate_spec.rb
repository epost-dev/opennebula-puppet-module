#!/usr/bin/env ruby
require 'spec_helper'

provider_class = Puppet::Type.type(:onetemplate).provider(:onetemplate)

describe provider_class do
  let(:resource ) {
    Puppet::Type::Onetemplate.new({
      :name    => 'app',
      :disks   => [:one, :two],
      :nics    => [:one, :two],
      :memory  => '256',
      :cpu     => '2',
    })
  }

  let(:response) {{
    :show => File.read('spec/fixtures/opennebula/xml/onetemplate_show.xml'),
    :list => File.read('spec/fixtures/opennebula/xml/onetemplate_list.xml'),
    :create => File.read('spec/fixtures/opennebula/xml/onetemplate_create.xml'),
  }}

  let(:provider) {
    provider = provider_class.new(:name => 'app')
    provider.resource = resource
    provider
  }

  context 'dynamic property bindings' do
    before(:each) do
      provider.stubs(:invoke).returns(response[:show]).once
    end

    it 'should have read access to memory' do
      provider.memory.should eq ["128"]
      expect { provider.memory = "1024" }.to raise_error(RuntimeError, /Can not yet modify memory on a onetemplate./)
    end

    it 'should have read access to cpu' do
      provider.cpu.should eq ["0.1"]
      expect { provider.cpu = "8" }.to raise_error(RuntimeError, /Can not yet modify cpu on a onetemplate./)
    end
  end

  context 'template handler' do
    it 'should create a template' do

      temp = Tempfile.new('my-testrun')
      Tempfile.stubs(:new).returns(temp)
      temp.stubs(:write).with(response[:create])

      provider.stubs(:invoke).with('create', temp.path).once
      provider.create
    end

    it "should list templates" do
      provider_class.stubs(:invoke).with('list', '--xml').returns(response[:list]).once
      provider_class.stubs(:invoke).with('show', 'app', '--xml').returns(response[:show]).times(6)
      provider_class.stubs(:invoke).with('show', 'database', '--xml').once

      template = provider_class.resources.first

      provider.resource = template

      provider.name.should eq "app"
      provider.memory.should eq ["128"]
      provider.cpu.should eq ["0.1"]
      provider.vcpu.should eq ["2"]
      provider.nic_model.should eq ["virtio", "virtio"]
      provider.os_boot.should eq ["hd"]
    end

    it "should list existing templates" do
      provider_class.stubs(:invoke).
        with('list', '--xml').returns(response[:list]).once
      provider_class.onetemplate_list.should eq ['app', 'database']

      provider_class.stubs(:invoke).
        with('list', '--xml').returns('<VMTEMPLATE_POOL></VMTEMPLATE_POOL>').once
      provider_class.onetemplate_list.should eq []
    end

    context "detect templates" do
      before(:each) do
        provider_class.stubs(:invoke).
          with('list', '--xml').
          returns(response[:list]).once
      end

      it "that exist" do
        provider.exists?.should be true
      end

      it "don't exist" do
        provider.resource[:name] = "doesntexist"
        provider.exists?.should be false
      end
    end

    it "should delete a template" do
      provider_class.stubs(:invoke).with('delete', 'app').once
      provider.destroy
    end
  end
end
