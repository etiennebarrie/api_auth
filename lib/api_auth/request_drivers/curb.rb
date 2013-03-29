module ApiAuth

  module RequestDrivers # :nodoc:

    class CurbRequest < Request # :nodoc:

      def headers
        @request.headers
      end

      def populate_content_md5
        nil #doesn't appear to be possible
      end

      def md5_mismatch?
        false
      end

      def request_uri
        @request.url
      end

    end

  end

end
