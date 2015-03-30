require 'socket'

module Yars
  # Server class which listens for requests
  class Server
    def initialize(app:, port: 8000, host: 'localhost', options: {})
      @app = app
      @host = host
      @options = options
      @port = port
    end

    def self.start(app:, port: 8000, host: 'localhost', options: {})
      new(app: app, port: port, host: host, options: options).start
    end

    def start
      puts "-> Booting yars on #{@host}:#{@port}"
      puts '-> Press Ctrl-c to stop'

      boot_tcp_server
    end

    private

    def boot_tcp_server
      @backend = TCPServer.new @host, @port

      loop do
        begin
          client = @backend.accept
          client.puts 'Hello world!'
        rescue SystemExit, Interrupt
          puts "\nSIGINT caught, exiting safely..."
          exit!
        ensure
          client.close
        end
      end
    end

    def spawn_frontend_workers
    end

    def spawn_backend_workers
    end
  end
end
