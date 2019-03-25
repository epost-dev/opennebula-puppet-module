source ENV['GEM_SOURCE'] || "https://rubygems.org"

if RUBY_VERSION < "2.0.0"
  gem "json_pure", "< 2.0.0" # json_pure 2.x requires ruby 2.x
end

gem 'rspec', '<3.0.0'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
  if puppetversion == '3.1.1'
    rspec_puppetversion = '=2.5.0'
  else
    rspec_puppetversion = '~>2.6.4'
  end
else
  gem 'puppet', '< 4', :require => false
end

group :development, :test do
  gem 'rspec-puppet',  rspec_puppetversion,          :require => false
  gem 'rspec-puppet-utils',      :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'puppet-lint',             :require => false
  gem 'simplecov',               :require => false
  if RUBY_VERSION < '1.9.3'
    gem 'retriable', '< 2'
    gem 'addressable', '< 2.4'
  end
  if RUBY_VERSION =~ /1.8/
    gem 'nokogiri',  '<= 1.5.10'
    gem 'highline', '<= 1.7.0'
    gem 'rake', '10.5.0'
  else
    gem 'nokogiri', "< 1.10",  :require => false
    gem 'rake', '< 12'
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


# puppet lint plugins
# https://puppet.community/plugins/#puppet-lint
gem 'puppet-lint-appends-check'                                 , :require => false
gem 'puppet-lint-classes_and_types_beginning_with_digits-check' , :require => false
gem 'puppet-lint-empty_string-check'                            , :require => false
gem 'puppet-lint-file_ensure-check'                             , :require => false
gem 'puppet-lint-leading_zero-check'                            , :require => false
gem 'puppet-lint-numericvariable'                               , :require => false
gem 'puppet-lint-resource_reference_syntax'                     , :require => false
gem 'puppet-lint-security-plugins'                              , :require => false
gem 'puppet-lint-spaceship_operator_without_tag-check'          , :require => false
gem 'puppet-lint-strict_indent-check'                           , :require => false
gem 'puppet-lint-trailing_comma-check'                          , :require => false
gem 'puppet-lint-trailing_newline-check'                        , :require => false
gem 'puppet-lint-undef_in_function-check'                       , :require => false
gem 'puppet-lint-unquoted_string-check'                         , :require => false
gem 'puppet-lint-usascii_format-check'                          , :require => false
gem 'puppet-lint-variable_contains_upcase'                      , :require => false
gem 'puppet-lint-version_comparison-check'                      , :require => false

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
