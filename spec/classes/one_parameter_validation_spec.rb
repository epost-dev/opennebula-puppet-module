# validation for the ssh key parameters is tested in a dedicated spec
# since that spec requires an empty hiera fixture
require 'spec_helper'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one', :type => :class do
  OS_FACTS.each do |f|
    context "On #{f[:operatingsystem]} #{f[:operatingsystemmajrelease]}" do
      let(:facts) { f }
      %w<xmlrpc_maxconn xmlrpc_maxconn_backlog xmlrpc_keepalive_timeout xmlrpc_keepalive_max_conn xmlrpc_timeout>.each do |param|
        context "given a non-string value for #{param}" do
          let(:params) {
            { param => ["foo", "bar"] }
          }
          it do
            is_expected.to compile.and_raise_error(/is not a string.  It looks to be a Array at/)
          end
        end
        context "given a string value for #{param}" do
          let(:params) {
            { param => "foobar" }
          }
          it do
            is_expected.to compile
          end
        end
      end
      %w<inherit_datastore_attrs hook_scripts_pkgs>.each do |param|
        context "given a non-array value for #{param}" do
          let(:params) {
            {
              param => "string"
            }
          }
          it do
            is_expected.to compile.and_raise_error(/is not an Array.  It looks to be a String at/)
          end
        end
        context "given an array value for #{param}" do
          let(:params) {
            {
              param => ["foo", "bar"]
            }
          }
          it do
            is_expected.to compile
          end
        end
      end
      context "validating hook scripts" do
        context "given a non-hash value for hook_scripts" do
          let(:params) {{ "hook_scripts" => "string"  }}
          it do
            is_expected.to compile.and_raise_error(/is not a Hash.  It looks to be a String at/)
          end
        end
        context "given a non-hash value for vm_hook_scripts" do
          let(:params) {{ "hook_scripts" => { "VM" => "string"}  }}
          it do
            is_expected.to compile.and_raise_error(/is not a Hash.  It looks to be a String at/)
          end
        end
        context "given a non-hash value for host_hook_scripts" do
          let(:params) {{ "hook_scripts" => { "HOST" => "string"}  }}
          it do
            is_expected.to compile.and_raise_error(/is not a Hash.  It looks to be a String at/)
          end
        end
        context "given the expeted format for hook_scripts" do
          let(:params) do
             {
               "hook_scripts" => {
                 "HOST" => {"foo" => "bar"},
                 "VM"   => {"foo" => "bar"}
               }
             }
          end
          it do
            is_expected.to compile
          end
        end
      end
      context "validating ssh keys" do
        let(:hiera_config) { nil }
        context "missing the mandatory pubkey" do
          let(:params) {{}}
          it do
            is_expected.to compile.and_raise_error(/The ssh_pub_key is mandatory for all nodes/)
          end
        end
        context "passing the mandatory pubkey" do
          let(:params) {{
            "ssh_pub_key" => 'ssh pub key'
          }}
          it do
            is_expected.to compile
          end
        end
        context "missing the mandatory private key for one::head" do
          let(:params) do
            {
              "node"        => false,
              "ssh_pub_key" => 'ssh pub key'
            }
          end
          it do
            is_expected.to compile.and_raise_error(/The ssh_priv_key_param is mandatory for the head/)
          end
        end
        context "passing the mandatory private key for one::head" do
          let(:params) do
            {
              "node"               => false,
              "ssh_pub_key"        => 'ssh pub key',
              "ssh_priv_key_param" => "ssh-dsa priv key"
            }
          end
          it do
            is_expected.to compile
          end
        end
      end
    end
  end
end
