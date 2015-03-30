require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

task default: :spec

task :server do
  require 'rubygems'
  require 'bundler/setup'
  require 'yars'

  Yars::Server.start app: {}
end
