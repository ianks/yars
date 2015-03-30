require 'rack/handler'
require 'yars'

module Rack
  # We register with the handler lack can load our server.
  module Handler
    # We boot the server here
    class Yars
      def self.run(app, options = {}, &block)
        app = Rack::Builder.new(&block).to_app if block_given?
        host = options.delete(:Host) || 'localhost'
        port = options.delete(:Port) || 8080
        server = ::Yars::Server.new(
          host: host, port: port, app: app, options: options
        )

        yield server if block_given?

        server.start
      end

      def self.valid_options
        {
          'Host=HOST'       => 'Hostname to listen on (default: locahost)',
          'Port=PORT'       => 'Port to listen on (default: 8080)',
          'Concurrency=NUM' => 'Number of threads to run (default: 16)'
        }
      end
    end

    register :yars, Yars
  end
end
