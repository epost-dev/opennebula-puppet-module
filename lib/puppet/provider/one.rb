##############################################################################
# Environment Configuration
##############################################################################
ONE_LOCATION=ENV["ONE_LOCATION"]

if !ONE_LOCATION
    RUBY_LIB_LOCATION="/usr/lib/one/ruby"
else
    RUBY_LIB_LOCATION=ONE_LOCATION+"/lib/ruby"
end

$: << RUBY_LIB_LOCATION

##############################################################################
# Required libraries
##############################################################################
require 'opennebula'

class Puppet::Provider::One < Puppet::Provider

  def client
    @client ||= OpenNebula::Client.new(
      File.read('/var/lib/one/.one/one_auth'),
      'http://localhost:2633/RPC2'
    )
  end

  def self.client
    @client ||= OpenNebula::Client.new(
      File.read('/var/lib/one/.one/one_auth'),
      'http://localhost:2633/RPC2'
    )
  end

end
