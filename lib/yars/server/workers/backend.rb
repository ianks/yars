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
        end

        def render_response
          client = @server.clients.pop
          env = read_request_buffer client
          status, headers, body = @server.app.call env
          response = Response.new status, headers, body

          client.print response.status
          client.print response.headers
          client.print response.body

          client.close
        end

        def read_request_buffer(client)
          return {} if client.eof?

          parser = Http::Parser.new

          # Return parsed http when complete
          parser.on_message_complete = proc { return parser.headers }

          # Begin reading and parsing data in 4KB blocks
          loop { parser << client.readpartial(1024) }
        end
      end
    end
  end
end
