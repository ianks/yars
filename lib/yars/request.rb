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
      @raw = raw
      @parsed = read_buffer
    end

    def etag
      Digest::MD5.new { @raw }.to_s
    end

    private

    def read_buffer
      return NullRequest.new if @from.eof?

      parser = Http::Parser.new

      # Return parsed http when complete
      parser.on_message_complete = proc do
        return parser
      end

      # Begin reading and parsing data in 4KB blocks
      loop do
        buf = @from.readpartial 1024
        @raw << buf
        parser << buf
      end
    end
  end
end
