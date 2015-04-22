module Yars
  class Server
    module Workers
      # Workers which respond to initial HTTP requests.
      class Frontend < Worker
        def spawn
          loop do
            begin
              worker = @server.backend.accept
              @server.clients << worker
            rescue => e
              puts e
            end
            # worker = Thread.start @server.backend.accept do |client|
            #   @server.clients << client
            # end

            # @workers << worker.tap { |w| w.abort_on_exception = true }
          end
        end
      end
    end
  end
end
