module ApiAuth

  module RequestDrivers # :nodoc:

    class ActionControllerRequest < Request # :nodoc:

      def headers
        @request.env
      end

      def body
        if @request.body
          @request.raw_post
        end
      end

      def post_or_put_request?
        @request.post? || @request.put?
      end

      def request_uri
        @request.request_uri
      end

    end

  end

end
