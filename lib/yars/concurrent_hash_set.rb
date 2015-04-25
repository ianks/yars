require 'thread'
require 'concurrent'

module Yars
  # BaseHashSet
  class ConcurrentHashSet
    def initialize(capacity)
      @capacity, @size = capacity, 0
      @table = Array.new(capacity).map { [] }
      @locks = Array.new(capacity).map { Mutex.new }
      @owner = Concurrent::AtomicMarkableReference.new
    end

    def [](key)
      acquire key

      bucket = bucket_location key

      return @table[bucket].find { |k, _v| k == key }[1]
    ensure
      release key
    end

    def []=(key, value)
      acquire key

      begin
        bucket = bucket_location key

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
      @locks[lock_location(x)].lock
    end

    def release(x)
      @locks[lock_location(x)].unlock
    end

    def policy
      (@size / @table.length) > 4
    end

    def resize
      old_capacity = @table.length
      @locks.each(&:lock)

      # Race condition
      return if old_capacity != @table.length

      new_capacity = 2 * old_capacity
      old_table = @table
      @table = Array.new(new_capacity).map { [] }

      old_table.each do |bucket|
        bucket.each do |item|
          @table[bucket_location(item)] << item
        end
      end

      return new_capacity

    ensure
      @locks.each(&:unlock)
    end

    def bucket_location(x)
      (x.hash % @table.length).abs
    end

    def lock_location(x)
      (x.hash % @locks.length).abs
    end
  end
end
