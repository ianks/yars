module Yars
  class Server
    module Workers
      # Backend workers which render responses to the client
      class Backend < Worker
        NUM_WORKERS = 4

        def spawn
          NUM_WORKERS.times do
            worker = Thread.new do
              loop do
                @server.render_response
              end
            end

            @workers << worker.tap { |w| w.abort_on_exception = true }
          end
        end
      end
    end
  end
end
