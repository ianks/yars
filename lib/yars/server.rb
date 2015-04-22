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
      puts "-> Booting yars on #{@host}:#{@port}"
      puts '-> Press Ctrl-c to stop'
      boot_tcp_server
    rescue SystemExit, Interrupt
      say "\nSIGINT caught, exiting safely..."
      @pools.each(&:kill)
      exit!
    end

    private

    def boot_tcp_server
      @backend = TCPServer.open @host, @port

      # Spawn thread pools for workers
      @pools << Workers::Backend.spawn!(self)
      @pools << Workers::Frontend.spawn!(self)

      @pools.each { |t| t.abort_on_exception = true }
      @pools.each(&:join)
    end
  end
end
