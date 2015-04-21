require 'concurrent'

module Yars
  # A thread safe queue built using monitors
  class AtomicQueue
    attr_reader :size

    def initialize
      sentinel = Node.new

      @head = Concurrent::Atomic.new sentinel
      @tail = Concurrent::Atomic.new sentinel
    end

    def <<(data)
      node = Node.new data: data

      loop do
        last = @tail.get
        succ = last.succ.get

        if last == @tail.get
          if succ.nil?
            if last.succ.compare_and_set succ, node
              @tail.compare_and_set last, node
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
        succ = first.succ.get

        if first == @head.get
          if first == last
            return nil if succ.nil?

            @tail.compare_and_set last, succ
          else
            val = succ.data
            return val if @head.compare_and_set first, succ
          end
        end
      end
    end

    def empty?
      @size == 0
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

  class RequestQueue < AtomicQueue; end
end
