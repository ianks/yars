require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

task default: :spec

task :server do
  require 'rubygems'
  require 'bundler/setup'
  require 'yars'

  body = "<html><body><h1>#{Time.now}</h1></body></html>\r\n"
  headers = { 'Content-Type' => 'text/html' }
  app = ->(_env) { Rack::Response.new(body, 200, headers).finish }

  Rack::Handler::Yars.run app
end

task :benchmark do
  server = fork { Rake::Task['server'].invoke }
  sleep 1
  puts "\n============ Results ============"
  system 'wrk -t8 -c400 -d5 -H "Accept: text/json" http://localhost:8000'
  puts "=================================\n"
  Process.kill 'SIGINT', server
end
