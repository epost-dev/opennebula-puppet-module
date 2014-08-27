#!/usr/bin/env rspec

require 'spec_helper'

provider_class = Puppet::Type.type(:onetemplate).provider(:onetemplate)
describe provider_class do
  let(:resource ) {
    Puppet::Type::Onetemplate.new({
      :name => 'new_cluster',
    })
  }
  let(:provider) {
    provider = provider_class.new(:name => "my_tester")
    provider.resource = resource
    provider
  }
  context 'with dynamic property bindings' do
    before(:each) do
      response = "<VMTEMPLATE><TEMPLATE><CPU><![CDATA[4]]></CPU><MEMORY><![CDATA[512]]></MEMORY></TEMPLATE></VMTEMPLATE>"
      provider_class.stubs(:invoke).returns(response).once
    end

    it 'should have read access to memory' do
      provider.memory.should == ["512"]
      expect { provider.memory = "1024" }.to raise_error(RuntimeError, /Can not yet modify memory on a onetemplate./)
    end

    it 'should have read access to cpu' do
      provider.cpu.should == ["4"]
      expect { provider.cpu = "8" }.to raise_error(RuntimeError, /Can not yet modify cpu on a onetemplate./)
    end
  end
end
