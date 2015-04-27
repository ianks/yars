module Yars
  class Server
    module Workers
      # Abstract worker for the server
      class Worker
        def initialize(server)
          @server = server
          @workers = []
          post_initialize
        end

        def post_initialize; end

        def self.spawn!(server)
          puts "#{self} spawned."
          @manager = Thread.start { new(server).spawn }
        end

        def kill
          @workers.each(&:kill)
          @manager.kill
        end

        def concurrency
          majority = (@server.concurrency * 0.66).to_i
          minority =  @server.concurrency - majority

          case self
          when Backend  then majority
          when Frontend then minority
          end
        end
      end
    end
  end
end

require 'yars/server/workers/frontend'
require 'yars/server/workers/backend'
