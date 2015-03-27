source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake',                    :require => false
  gem 'rspec-puppet',            :require => false, :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'puppet-lint',             :require => false
  gem 'simplecov',               :require => false
  gem 'nokogiri',                :require => false
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
  gem 'puppet', :require => false
end
