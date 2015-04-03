module Yars
  class AtomicQueue
    def initialize
      @head = Node.new pred: @tail
      @tail = Node.new succ: @head
    end

    def <<(data)
      new_node = Node.new data: data, succ: @tail.next, pred: @tail
      @tail.next.prev = new_node
      self
    end

    def pop
    end

    private

    class Node
      attr_accessor :data, :succ, :pred

      def initialize(data: nil, succ: nil, pred: nil)
        @data, @succ, @pred = data, succ, prec
      end

      alias_method :next, :succ
      alias_method :prev, :pred
    end
  end

  class RequestQueue < Queue; end
end
