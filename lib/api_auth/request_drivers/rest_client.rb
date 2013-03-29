module ApiAuth

  module RequestDrivers # :nodoc:

    class RestClientRequest < Request # :nodoc:

      def headers
        @request.headers
      end

      def body
        return '' unless @request.payload
        @request.payload.read
      end

      def request_uri
        uri = @request.parse_url_with_auth(@request.url)
        uri.request_uri
      end

    end

  end

end
