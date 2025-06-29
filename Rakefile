# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Run tests with coverage"
task :test do
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
    add_filter "/vendor/"
    minimum_coverage 90
  end
  
  Rake::Task[:spec].invoke
end

desc "Run RuboCop"
task :rubocop do
  require "rubocop"
  RuboCop::CLI.new.run
end

desc "Run all checks"
task :check => [:rubocop, :spec]

desc "Build and install gem locally"
task :install => :build do
  sh "gem install pkg/sabre_api_ruby-#{SabreApiRuby::VERSION}.gem"
end 