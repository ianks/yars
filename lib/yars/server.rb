module Yars
  # Server class which listens for requests
  class Server
    def initialize(host, port, app, options)
      @host = host
      @port = port.to_i
      @app = app
      @options = options
    end

    def start
    end
  end
end
