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

task :benchmark do
  system 'wrk -t8 -c400 -d10 http://localhost:8000'
end
