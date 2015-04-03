module Yars
  class Server
    module Workers
      # Workers which respond to initial HTTP requests.
      class Frontend < Worker
        def spawn
          loop do
            # When we recieve a client, spawn a thread to handle it, to
            # ensure the server is not blocked by slow clients.
            worker = Thread.start @server.backend.accept do |client|
              @server.clients << client
            end

            # Make sure we abort the thread when an exception is raised.
            @workers << worker.tap { |w| w.abort_on_exception = true }
          end
        end
      end
    end
  end
end
