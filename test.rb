require 'bundler'
Bundler.setup
require 'yars'

app = lambda do |_env|
  body = <<-html
  <html>
    <h1>Hello</h1>
    <p>Professor Pavlov plz give me A</p1>
    <p>"#{_env}</p>"
  </html>
  html

  Rack::Response.new(body, 200, {'Content-Type' => 'text/html'}).finish
end

Rack::Handler::Yars.run app
