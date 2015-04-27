require 'yars/server/workers'

require 'http/parser'
require 'rack'
require 'socket'
require 'thread'
require 'logger'

module Yars
  # Server class which listens for requests
  class Server
    attr_accessor :app, :backend, :clients, :pools, :logger, :concurrency

    def initialize(app:, port: 8080, host:, options: {})
      @app = app
      @clients = RequestQueue.new
      @concurrency = options[:concurrency] || 16
      @caching = options[:caching] || false
      @host = host
      @mutex = Mutex.new
      @options = options
      @pools = []
      @port = port

      setup_logger
    end

    def self.start(app:, port: 8080, host: 'localhost', options: {})
      new(app: app, port: port, host: host, options: options).start
    end

    def start
      puts "-> Booting yars on http://#{@host}:#{@port}"
      puts "-> Concurrency is set to #{@concurrency}"
      puts '-> Press Ctrl-c to stop'

      boot_tcp_server
    rescue SystemExit, Interrupt
      puts "\nSIGINT caught, exiting safely..."
      @pools.each(&:kill)

      exit!
    end

    def caching?
      @caching
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

    def setup_logger
      require 'fileutils'

      FileUtils.mkdir_p 'log'
      file = File.open 'log/yars.log', File::WRONLY | File::APPEND | File::CREAT
      @logger = Logger.new file
    end
  end
end
