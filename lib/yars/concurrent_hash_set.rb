require 'thread'
require 'concurrent'

module Yars
  # BaseHashSet
  class ConcurrentHashSet
    def initialize(capacity = 20)
      @locks = Array.new(capacity).map { Mutex.new }
      @owner = Concurrent::AtomicMarkableReference.new
      @size = 0
      @table = Array.new(capacity).map { [] }
    end

    def [](key)
      acquire key

      bucket = index_of key, length: @table.length

      val = @table[bucket].find { |k, _v| k == key }

      return val.is_a?(Array) ? val[1] : nil
    ensure
      release key
    end

    def []=(key, value)
      acquire key

      begin
        bucket = index_of key, length: @table.length

        unless @table[bucket].include? [key, value]
          result = @table[bucket] << [key, value]
          @size += 1
        end

      ensure
        release key
      end

      resize if policy

      result ? self : result
    end

    private

    def acquire(x)
      me = Thread.current

      loop do
        who, mark = @owner.get

        loop do
          who, mark = @owner.get
        end while mark && who != me

        old_locks = @locks
        old_lock = old_locks[index_of x, length: old_locks.length]
        old_lock.lock
        who, mark = @owner.get

        return if (!mark || who == me) && @locks == old_locks

        old_lock.unlock
      end
    end

    def release(x)
      @locks[index_of x, length: @locks.length].unlock
    end

    def policy
      (@size / @table.length) > 4
    end

    def resize
      new_capacity = 2 * @table.length

      if @owner.compare_and_set nil, Thread.current, false, true
        return if @table.length != new_capacity

        quiesce

        old_table = @table

        @table = Array.new(new_capacity).map { [] }
        @locks = Array.new(new_capacity).map { Mutex.new }

        rehash old_table

        return @table
      end
    ensure
      @owner.set nil, false
    end

    def quiesce
      @locks.each { |lock| loop while lock.locked? }
    end

    def index_of(x, length:)
      (x.hash % length).abs
    end

    def rehash(old_table)
      new_capacity = @table.length

      old_table.each do |bucket|
        bucket.each do |item|
          @table[index_of item, length: new_capacity] << item
        end
      end
    end
  end

  class AtomicCache < ConcurrentHashSet; end
end
