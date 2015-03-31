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
  system 'wrk -t8 -c400 -d10 http://localhost:8000'
end
