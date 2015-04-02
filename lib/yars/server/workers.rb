module Yars
  class Server
    module Workers
      # Abstract worker for the server
      class Worker
        def initialize(server)
          @server = server
          @workers = []
        end

        def self.spawn!(server)
          Thread.new { new(server).spawn }
        end

        def kill
          @workers.each(&:kill)
        end
      end
    end
  end
end

require 'yars/server/workers/frontend'
require 'yars/server/workers/backend'
