require 'socket'
require 'thread'
require 'http/parser'

module Yars
  # Server class which listens for requests
  class Server
    def initialize(app:, port: 8000, host: 'localhost', options: {})
      @app = app
      @clients = Queue.new
      @host = host
      @mutex = Mutex.new
      @options = options
      @pools = []
      @port = port
    end

    def self.start(app:, port: 8000, host: 'localhost', options: {})
      new(app: app, port: port, host: host, options: options).start
    end

    def start
      say "-> Booting yars on #{@host}:#{@port}"
      say '-> Press Ctrl-c to stop'

      boot_tcp_server
    end

    private

    def boot_tcp_server
      @backend = TCPServer.new @host, @port

      @pools << Thread.new { spawn_frontend_workers }
      @pools << Thread.new { spawn_backend_workers }

      @pools.each { |t| t.abort_on_exception = true }
      @pools.each(&:join)
    end

    def spawn_frontend_workers
      loop do
        begin
          Thread.start(@backend.accept) do |client|
            @clients << client
          end
        rescue SystemExit, Interrupt
          say "\nSIGINT caught, exiting safely..."
          @pools.each(&:kill)
          exit!
        end
      end
    end

    def spawn_backend_workers
      4.times do
        Thread.new do
          loop do
            client = @clients.pop
            client.puts @app.call.to_s
            client.close
          end
        end
      end
    end

    def read_request_buffer(client)
      parser = Http::Parser.new

      # Begin reading and parsing data in 4KB blocks
      loop do
        begin
          data = client.readpartial 4096
          parser << data

          break if parser.headers
        end
      end

      parser.headers.to_s
    end

    def say(*args)
      @mutex.synchronize { puts args }
    end
  end
end
