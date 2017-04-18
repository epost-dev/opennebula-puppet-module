require 'rake'
require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint'

desc 'Run the tests'
RSpec::Core::RakeTask.new(:do_test) do |t|
  t.rspec_opts = ['--color', '-f d']
  file_list = FileList['spec/**/*_spec.rb']
  %w(support fixtures acceptance).each do |exclude|
    file_list = file_list.exclude("spec/#{exclude}/**/*_spec.rb")
  end
  t.pattern = file_list
end

desc 'Generate the docs'
RSpec::Core::RakeTask.new(:doc) do |t|
  t.rspec_opts = ['--format', 'documentation']
  t.pattern = 'spec/*/*_spec.rb'
end

PuppetLint::RakeTask.new(:lint) do |config|
  # Pattern of files to check, defaults to `**/*.pp`
  config.pattern = 'manifests/**/*.pp'

  # Pattern of files to ignore
  #config.ignore_paths = ['vendor/**/*.pp']

  # List of checks to disable
  config.disable_checks = ['80chars', 'class_inherits_from_params_class']

  # Should the task fail if there were any warnings, defaults to false
  #config.fail_on_warnings = true

  # Print out the context for the problem, defaults to false
  # config.with_context = true
end

task :default => [:spec_prep, :lint, :do_test, :spec_clean]
task :test => [:default]

desc "Run Acceptance tests on CI with multiple nodes"
  task :ci  do
    sh('RS_SET=ci bundle exec rake beaker')
  end
