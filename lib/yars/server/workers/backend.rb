require 'digest'

module Yars
  class Server
    module Workers
      # Backend workers which render responses to the client
      class Backend < Worker
        NUM_WORKERS = 4

        def post_initialize
          @lookup_cache = ::Yars::AtomicCache.new
        end

        def spawn
          NUM_WORKERS.times do
            worker = Thread.new do
              loop do
                serve @server.clients.pop
              end
            end

            @workers << worker.tap do |w|
              w.abort_on_exception = true
            end
          end
        end

        def serve(client)
          request = Request.new from: client
          etag = request.etag

          # If the response is cached, ship that
          if @lookup_cache[etag]
            response = @lookup_cache[etag]
          else
            response = response_from_application env: request.parsed.headers
          end

          ship response, to: client

          # Cache the response
          @lookup_cache[etag] = response unless @lookup_cache[etag]
        end

        private

        def response_from_application(env:)
          status, headers, body = @server.app.call env
          Response.new status, headers, body
        end

        def ship(response, to:)
          to.print response.status
          to.print response.headers
          to.print response.body
          to.close
        end
      end
    end
  end
end
