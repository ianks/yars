require 'http/parser'

module Yars
  # Null object in case of malformed response
  class NullRequest
    attr_accessor :status, :headers, :body
  end

  # Request object for handling client requests
  class Request
    attr_accessor :parsed

    def initialize(from:)
      @from = from
      @parsed = read_buffer
      @raw = parsed
    end

    def etag
      @raw.hash
    end

    private

    def read_buffer
      @from.read_nonblock 1024

      rescue IO::WaitReadable, Errno::EAGAIN
        IO.select [@from], nil, nil, 1
        retry
    end
  end
end
