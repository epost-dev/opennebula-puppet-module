# -*- coding: utf-8 -*-
require 'spec_helper'
require 'puppet/util/opennebula'

describe Puppet::Util::Opennebula::CLI do
  context "runs one-commands" do
    let(:subject) {
      Puppet::Util::Opennebula::CLI::Command.from_credentials('some', 'login')
    }

    it "flattened and inline" do
      Open3.stubs(:popen3).with('mockety', '--mock', 'yourself', '--user', 'some', '--password', 'login').once
      subject.invoke("mockety", ["--mock", "yourself"]).should eq nil
    end
  end
  context "with authentication" do
    let(:subject) {
      File.stubs(:read).with('/var/lib/one/.one/one_auth').returns('myuser:mypassword').once
      Puppet::Util::Opennebula::CLI::Command.from_file
    }
    it "hands over the credentials to one" do
      Open3.stubs(:popen3).with('mockety', '--mock', 'yourself', '--user', 'myuser', '--password', 'mypassword').once
      subject.invoke("mockety", ["--mock", "yourself"]).should eq nil
    end
  end
end
