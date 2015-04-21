require 'thread'

module Yars
  class AtomicCache < Hash
    def initialize
      @write_lock = Mutex.new
      super
    end

    def []=(key, value)
      @write_lock.synchronize { super }
    end

    def [](key)
      @write_lock.synchronize { super }
    end

    alias_method :put, :[]=
    alias_method :get, :[]
  end
end
