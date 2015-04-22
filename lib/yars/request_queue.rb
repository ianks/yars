require 'concurrent'

module Yars
  # A thread safe queue built using monitors
  class AtomicQueue
    attr_reader :size

    def initialize
      sentinel = Node.new

      @mutex = Mutex.new
      @not_empty = ConditionVariable.new

      @head = Concurrent::Atomic.new sentinel
      @tail = Concurrent::Atomic.new sentinel
    end

    def <<(data)
      node = Node.new data: data

      loop do
        last = @tail.get
        succ = last.succ.get rescue nil

        if last == @tail.get
          if succ.nil?
            if last.succ.compare_and_set succ, node
              @tail.compare_and_set last, node
              @mutex.synchronize { @not_empty.broadcast }

              return node.data
            end
          else
            @tail.compare_and_set last, succ
          end
        end
      end
    end

    def pop
      loop do
        first = @head.get
        last = @tail.get
        succ = @head.get.succ.get

        # Await until there is work to be done
        if succ.nil?
          @mutex.synchronize do
            @not_empty.wait @mutex
            next
          end
        end

        if first == @head.get
          if first == last
            @tail.compare_and_set last, succ
          else
            return succ.data if @head.compare_and_set first, succ
          end
        end
      end
    end

    # Private node for the queue
    class Node
      attr_accessor :data, :succ

      def initialize(data: nil)
        @data = data
        @succ = Concurrent::Atomic.new nil
      end
    end
  end

  class RequestQueue < Queue; end
end
