module Yars
  class Server
    module Workers
      # Workers which respond to initial HTTP requests.
      class Frontend < Worker
        NUM_WORKERS = 8

        def spawn
          NUM_WORKERS.times { @workers << start_worker }

          @workers.each(&:join)
        rescue => err
          @server.logger.warn err.to_s
        end

        private

        def start_worker
          Thread.new { enter_work_loop }.tap do |t|
            t.abort_on_exception = true
          end
        end

        def enter_work_loop
          loop { accept_clients }
        end

        def accept_clients
          @server.clients << @server.backend.accept_nonblock

          rescue IO::WaitReadable, Errno::EAGAIN
            IO.select [@server.backend]
            retry
        end
      end
    end
  end
end
