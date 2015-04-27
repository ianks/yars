require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :spec

task default: :spec

task :server, [:concurrency] do |_t, args|
  boot_server args[:concurrency] || 16
end

task :benchmark, [:concurrency] do |_t, args|
  server = fork { boot_server(args[:concurrency] || 16) }
  sleep 1
  puts "\n============ Results ============"
  system 'wrk -t8 -c4000 -d20 -s tasks/get.lua http://localhost:8000'
  puts "=================================\n"
  Process.kill 'SIGINT', server
end

task :pandoc do
  system 'pandoc ANALYSIS.md -o YARS-MultiThreadedWebServer.pdf'
end

def boot_server(concurrency)
  require 'rubygems'
  require 'bundler/setup'
  require 'yars'

  body = <<-html
  <html>
    <h1>Hello world!</h1>
    <p>It is currently #{Time.now}</p>
  </html>
  html

  app = lambda do |env|
    headers = { 'Content-Type' => 'text/html' }

    body = <<-html
      <html>
        <h1>Hello world!</h1>
        <h3>It is currently #{Time.now}</h3>
        <p>#{env.gsub "\r\n", '<br>' }</p>
      </html>
    html

    Rack::Response.new(body, 200, headers).finish
  end

  Rack::Handler::Yars.run(
    app,
    concurrency: concurrency.to_i,
    Port: 8000,
    caching: true
  )
end
