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
                render_response
              end
            end

            @workers << worker.tap { |w| w.abort_on_exception = true }
          end

          def render_response
            client = @server.clients.pop
            env = @server.read_request_buffer client
            status, headers, body = @server.app.call env
            response = Response.new status, headers, body

            client.print response.status
            client.print response.headers
            client.print response.body

            client.close
          end
        end
      end
    end
  end
end
