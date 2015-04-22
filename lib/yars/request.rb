require 'http/parser'
require 'ostruct'

module Yars
  # Null object in case of malformed response
  class NullRequest
    attr_accessor :status, :headers, :body
  end

  # Request object for handling client requests
  class Request
    attr_accessor :parsed

    def initialize(from:, raw: '')
      @from = from
      @parsed = read_buffer
      @raw = parsed
    end

    def etag
      Digest::MD5.new { @raw }.to_s
    end

    private

    def read_buffer
      @from.read_nonblock 1024

      rescue IO::WaitReadable
        IO.select [@from], nil, nil, 0.01
    end
  end
end
