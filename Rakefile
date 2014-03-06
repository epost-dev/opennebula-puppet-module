require 'rake'
require 'rake/tasklib'
require 'rspec/core/rake_task'
require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint'

desc 'Run the tests'
RSpec::Core::RakeTask.new(:do_test) do |t|
  t.rspec_opts = ['--color', '-f d']
  t.pattern = 'spec/*/*_spec.rb'
end

desc 'Generate the docs'
RSpec::Core::RakeTask.new(:doc) do |t|
  t.rspec_opts = ['--format', 'documentation']
  t.pattern = 'spec/*/*_spec.rb'
end


desc 'Run puppet-lint on the one manifests'
task :onelint do
  PuppetLint.configuration.send('disable_80chars')
  PuppetLint.configuration.ignore_paths = ['vendor/**/*.pp']
  PuppetLint.configuration.with_filename = true

  linter = PuppetLint.new
  matched_files = FileList['spec/fixtures/modules/one/manifests/**/*.pp']

  matched_files.to_a.each do |puppet_file|
    linter.file = puppet_file
    linter.run
  end

  fail if linter.errors? || (linter.warnings? && PuppetLint.configuration.fail_on_warnings)
end

task :default => [:spec_prep, :do_test, :onelint, :spec_clean]
task :test => [:default]
