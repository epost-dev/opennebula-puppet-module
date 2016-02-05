source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake',                    :require => false
  gem 'rspec-puppet',            :require => false
  gem 'rspec-puppet-utils',      :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'puppet-lint', :git => 'https://github.com/rodjek/puppet-lint.git', :require => false
  gem 'simplecov',               :require => false
  if RUBY_VERSION =~ /1.8/
      gem 'nokogiri',  '<= 1.5.10'
    else
      gem 'nokogiri',             :require => false
    end
end

group :integration do
  gem 'serverspec',              :require => false
  gem 'beaker',                  :require => false
  gem 'beaker-rspec',            :require => false
  gem 'vagrant-wrapper',         :require => false
  gem 'pry',                     :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
  if puppetversion < '3.0'
    gem 'hiera-puppet', :require => false
  end
else
  gem 'puppet', '< 4', :require => false
end

# puppet lint plugins
# https://puppet.community/plugins/#puppet-lint
gem 'puppet-lint-appends-check',
    :git => 'https://github.com/puppet-community/puppet-lint-appends-check.git',
    :require => false
gem 'puppet-lint-classes_and_types_beginning_with_digits--check',
    :git => 'https://github.com/puppet-community/puppet-lint-classes_and_types_beginning_with_digits-check.git',
    :require => false
gem 'puppet-lint-empty_string-check',
    :git => 'https://github.com/puppet-community/puppet-lint-empty_string-check.git',
    :require => false
gem 'puppet-lint-file_ensure-check',
    :git => 'https://github.com/puppet-community/puppet-lint-file_ensure-check.git',
    :require => false
gem 'puppet-lint-leading_zero-check',
    :git => 'https://github.com/puppet-community/puppet-lint-leading_zero-check.git',
    :require => false
gem 'puppet-lint-numericvariable',
    :git => 'https://github.com/fiddyspence/puppetlint-numericvariable.git',
    :require => false
gem 'puppet-lint-resource_reference_syntax',
    :git => 'https://github.com/tuxmea/puppet-lint-resource_reference_syntax.git',
    :require => false
gem 'puppet-lint-security-plugins',
    :git => 'https://github.com/floek/puppet-lint-security-plugins.git',
    :require => false
gem 'puppet-lint-spaceship_operator_without_tag-check',
    :git => 'https://github.com/puppet-community/puppet-lint-spaceship_operator_without_tag-check.git',
    :require => false
gem 'puppet-lint-strict_indent-check',
    :git => 'https://github.com/relud/puppet-lint-strict_indent-check.git',
    :require => false
gem 'puppet-lint-trailing_comma-check',
    :git => 'https://github.com/puppet-community/puppet-lint-trailing_comma-check.git',
    :require => false
gem 'puppet-lint-trailing_newline-check',
    :git => 'https://github.com/rodjek/puppet-lint-trailing_newline-check.git',
    :require => false
gem 'puppet-lint-undef_in_function-check',
    :git => 'https://github.com/puppet-community/puppet-lint-undef_in_function-check.git',
    :require => false
gem 'puppet-lint-unquoted_string-check',
    :git => 'https://github.com/puppet-community/puppet-lint-unquoted_string-check.git',
    :require => false
gem 'puppet-lint-usascii_format-check',
    :git => 'https://github.com/jpmasters/puppet-lint-usascii_format-check.git',
    :require => false
gem 'puppet-lint-variable_contains_upcase',
    :git => 'https://github.com/fiddyspence/puppetlint-variablecase.git',
    :require => false
gem 'puppet-lint-version_comparison-check',
    :git => 'https://github.com/puppet-community/puppet-lint-version_comparison-check.git',
    :require => false

# disabled lint plugins
#gem 'puppet-lint-file_source_rights-check',
#    :git => 'https://github.com/camptocamp/puppet-lint-file_source_rights-check.git',
#    :require => false
#gem 'puppet-lint-fileserver-check',
#    :git => 'https://github.com/camptocamp/puppet-lint-fileserver-check.git',
#    :require => false
#gem 'puppet-lint-global_resource-check',
#    :git => 'https://github.com/ninech/puppet-lint-global_resource-check.git',
#    :require => false
#gem 'puppet-lint-package_ensure-check',
#    :git => 'https://github.com/danzilio/puppet-lint-package_ensure-check.git',
#    :require => false
#gem 'puppet-lint-param-docs',
#    :git => 'https://github.com/domcleal/puppet-lint-param-docs.git',
#    :require => false
