module Yars
  # Abstract response object for yars
  class Response
    def initialize(status, body, headers)
      @status, @headers, @body = status, headers, body
    end

    def status
      "HTTP/1.1 #{@status} #{Rack::Utils::HTTP_STATUS_CODES[@status]}\r\n"
    end

    # Parse the env hash and coerce into HTTP header format
    def headers
      @headers.map do |k, v|
        "#{k}: #{v}"
      end.join("\r\n") << "\r\n\r\n"
    end

    # The body is an array-like object of data we have to loop through
    def body
      ''.tap do |ret|
        @body.each { |bod| ret << bod.to_s }
      end
    end
  end
end
