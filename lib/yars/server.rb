require 'yars/server/workers'

require 'http/parser'
require 'rack'
require 'socket'
require 'thread'

module Yars
  # Server class which listens for requests
  class Server
    attr_accessor :app, :backend, :clients, :pools

    def initialize(app:, port: 8000, host: 'localhost', options: {})
      @app = app
      @clients = RequestQueue.new
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

      begin
        boot_tcp_server
        # TODO: This logic likely does not belong here.
      rescue SystemExit, Interrupt
        say "\nSIGINT caught, exiting safely..."
        @pools.each(&:kill)
        exit!
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

    private

    def boot_tcp_server
      @backend = TCPServer.new @host, @port

      # Spawn thread pools for workers
      @pools << Workers::Frontend.spawn!(self)
      @pools << Workers::Backend.spawn!(self)

      @pools.each { |t| t.abort_on_exception = true }
      @pools.each(&:join)
    end

    def say(*args)
      @mutex.synchronize { puts args }
    end
  end
end
