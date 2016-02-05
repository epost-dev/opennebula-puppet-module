require 'spec_helper'

hiera_config = 'spec/fixtures/hiera/hiera.yaml'

describe 'one::oned::sunstone::config', :type => :class do
  OS_FACTS.each do |f|
    context "On #{f[:operatingsystem]} #{f[:operatingsystemmajrelease]}" do
      let(:facts) { f }
      let (:hiera_config) { hiera_config }
      let (:pre_condition) { 'include one' }

      context 'general' do
        it { should contain_class('one::oned::sunstone::config') }
        it { should contain_file('/usr/lib/one/sunstone') \
        .with_ensure('directory') \
        .with_owner('oneadmin') \
        .with_group('oneadmin') \
        .with_recurse('true')
        }
      end
      context 'with sunstone listen ip set' do
        let (:params) { {:listen_ip => '1.2.3.4'} }
        it { should contain_file('/etc/one/sunstone-server.conf') \
        .with_content(/:host: 1.2.3.4/m)
        }
      end
      context 'with sunstone listen not ip set' do
        it { should contain_file('/etc/one/sunstone-server.conf') \
        .with_group('oneadmin') \
        .with_content(/:host: /m)
        }
      end
      context 'with support enabled' do
        let (:params) { {:enable_support => 'yes'} }

        expected_routes = ':routes:
    - oneflow
    - vcenter
    - support'

        it { should contain_file('/etc/one/sunstone-server.conf') \
        .with_group('oneadmin') \
        .with_content(/#{expected_routes}/m)
        }
      end
      context 'with support disabled' do
        let (:params) { {:enable_support => 'no'} }

        unexpected_routes ='
    - vcenter
    - support'

        it { should_not contain_file('/etc/one/sunstone-server.conf').with_content(/#{unexpected_routes}/m) }
      end
    end
  end
end


describe 'sunstone_views template on 4.12' do

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  before(:each) do
    scope.stubs(:lookupvar).with('one::sunstone_logo_png').returns('undef')
    scope.stubs(:lookupvar).with('one::version_gte_4_14').returns(false)
  end

  it 'with marketplace enabled' do
    harness = TemplateHarness.new('spec/../templates/sunstone-views.yaml.erb', scope)
    harness.set('@enable_marketplace', 'yes')
    result = harness.run
    expect(result).to include("- marketplace-tab")
  end

  it 'with marketplace disabled' do
    harness = TemplateHarness.new('spec/../templates/sunstone-views.yaml.erb', scope)
    harness.set('@enable_marketplace', 'no')
    result = harness.run
    expect(result).to_not include("- marketplace-tab")
  end
end

describe 'sunstone_views template on 4.14' do

  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }
  before(:each) do
    scope.stubs(:lookupvar).with('one::sunstone_logo_small_png').returns('undef')
    scope.stubs(:lookupvar).with('one::version_gte_4_14').returns(true)
  end

  it 'with marketplace enabled' do
    harness = TemplateHarness.new('spec/../templates/sunstone-views-admin.yaml.erb', scope)
    harness.set('@enable_marketplace', 'yes')
    result = harness.run
    expect(result).to include("- marketplace-tab")
  end

  it 'with marketplace disabled' do
    harness = TemplateHarness.new('spec/../templates/sunstone-views-admin.yaml.erb', scope)
    harness.set('@enable_marketplace', 'no')
    result = harness.run
    expect(result).to_not include("- marketplace-tab")
  end
end
