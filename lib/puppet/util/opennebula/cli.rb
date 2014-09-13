# -*- coding: utf-8 -*-
require 'open3'

module Puppet::Util::Opennebula::CLI
  class Command
    attr_accessor :user, :password

    def initialize(user, password)
      self.user = user
      self.password = password
    end

    def self.from_file(file = '/var/lib/one/.one/one_auth')
      user, password = File.read(file).strip.split(':')
      new(user, password)
    end

    def self.from_credentials(user, password)
      new(user, password)
    end

    class << self
      alias default from_file
    end

    def invoke(bin, commands)
      commandline = [bin, commands, '--user', user, '--password', password].flatten

      output = Open3.popen3(*commandline) do |stdin, stdout, stderr|
        stdin.close()
        #TODO: Raise errors?
        stdout.read()
      end
      output
    end
  end

  module ClassMethods
    def binary
      name.to_s
    end

    def invoke(*commands)
      Puppet::Util::Opennebula::CLI::Command.default.invoke(binary, commands)
    end
  end

  module InstanceMethods
    def invoke(*commands)
      self.class.invoke(*commands)
    end
  end

  def self.included(klass)
    klass.send(:include, InstanceMethods)
    klass.send(:extend, ClassMethods)
  end
end
