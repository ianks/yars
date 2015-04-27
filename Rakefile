require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

task default: :spec

task :server, [:concurrency] do |_t, args|
  boot_server(args[:concurrency] || 16)
end

task :benchmark, [:concurrency] do |_t, args|
  benchmark(args[:concurrency] || 16)
end

task :profile do
  %w(2 4 6 8 12 16 24 32 64).each do |i|
    system "bundle exec rake benckmark[#{i}]"
    sleep 5
  end
end

task :pandoc do
  system 'pandoc ANALYSIS.md -o YARS-MultiThreadedWebServer.pdf'
end

def benchmark(concurrency)
  server = fork { boot_server(concurrency) }
  sleep 3
  puts '===='
  puts "Concurrency: #{concurrency}"
  system 'wrk -t8 -c4000 -d30 -s tasks/get.lua http://localhost:8192'
  puts "====\n"
  Process.kill 'SIGINT', server
end

def boot_server(concurrency)
  require 'rubygems'
  require 'bundler/setup'
  require 'yars'

  body = "<html><body><h1>Hello world!</h1></body></html>\n"
  headers = { 'Content-Type' => 'text/html' }
  app = ->(_env) { Rack::Response.new(body, 200, headers).finish }

  Rack::Handler::Yars.run(
    app,
    concurrency: concurrency.to_i,
    Port: 8192,
    caching: true,
    quiet: false
  )
end
