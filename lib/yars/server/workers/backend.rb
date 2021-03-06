module Yars
  class Server
    module Workers
      # Backend workers which render responses to the client
      class Backend < Worker
        def post_initialize
          @lookup_cache = ::Yars::AtomicCache.new
        end

        def spawn
          concurrency.times do
            worker = Thread.new do
              loop do
                begin
                  client = @server.clients.pop
                  serve client
                rescue => err
                  @server.logger.warn err.to_s
                ensure
                  client.close
                end
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
          if @server.caching? && @lookup_cache[etag]
            response = @lookup_cache[etag]
          else
            response = response_from_application env: request.parsed
          end

          ship response, to: client

          # Cache the response
          @lookup_cache[etag] = response if @server.caching?
        end

        private

        def response_from_application(env:)
          status, headers, body = @server.app.call env
          Response.new status, headers, body
        end

        def ship(response, to:)
          to.write_nonblock response.status
          to.write_nonblock response.headers
          to.write_nonblock response.body
        rescue IO::WaitReadable, Errno::EAGAIN
          IO.select [@to]
          retry
        end
      end
    end
  end
end
