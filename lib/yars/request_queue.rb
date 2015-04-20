require 'concurrent/atomics'

module Yars
  # A thread safe queue built using monitors
  class AtomicQueue
    attr_reader :size

    def initialize
      @head = Node.new pred: @tail
      @tail = Node.new succ: @head
      @size = 0
    end

    def <<(data)
      node = Node.new data: data, succ: @tail.succ, pred: @tail

      @head.pred = node if empty?
      @tail.succ.pred = node
      @tail.succ = node
      @size += 1

      self
    end

    def pop
      return nil if empty?

      @head.pred.data.tap do
        @head.pred = @head.pred.pred
        @size -= 1
      end
    end

    def empty?
      @size == 0
    end

    # Private node for the queue
    class Node
      attr_accessor :data, :succ, :pred

      def initialize(data: nil, succ: nil, pred: nil)
        @data, @succ, @pred = data, succ, pred
      end
    end
  end

  class RequestQueue < Queue; end
end
