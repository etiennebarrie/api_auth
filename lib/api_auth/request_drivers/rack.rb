module ApiAuth

  module RequestDrivers # :nodoc:

    class RackRequest < Request # :nodoc:

      def headers
        @request.env
      end

      def body
        @request.body.read
      end

      def method
        @request.request_method
      end

      def request_uri
        @request.url
      end

    end

  end

end
