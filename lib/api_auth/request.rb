module ApiAuth

  # A generic class to hide differences between objects representing HTTP
  # requests in different libraries, initialized with that object.
  #
  # Subclasses need to override, if necessary:
  #
  # * write_header(name, value)
  #   The default implementation calls #[]=(name, value) on #headers.
  #
  # * read_header(name)
  #   The default implementation calls #[](name) on #headers.
  #
  # * headers
  #   The default implementation returns the request object. If the underlying
  #   library accepts #[] and #[]= on an object to get or set the headers, this
  #   method should return that object.
  #
  # * body
  #   The default implementation calls #body on the request object.
  #
  # * request_uri
  #   The default implementation calls #path on the request object.
  #
  # * post_or_put_request?
  #   The default implementation calls #method on self, expects a capitalized
  #   String object. You can either define #method to behave this way, or
  #   return true if the request is a POST or PUT request.
  #
  # * method
  #   The default implementation calls .to_s.upcase on the result of calling
  #   #method on the request object. No need to implement this if
  #   #post_or_put_request? is implemented.
  class Request

    def initialize(request)
      @request = request
    end

    def content_md5
      find_header(%w(Content-MD5 CONTENT-MD5 CONTENT_MD5)) || ''
    end

    def timestamp
      find_header(%w(Date DATE HTTP_DATE)) || ''
    end

    def content_type
      find_header(%w(Content-Type CONTENT-TYPE CONTENT_TYPE HTTP_CONTENT_TYPE)) || ''
    end

    def set_auth_header(header)
      write_header('Authorization', header)
      @request
    end

    def authorization_header
      find_header %w(Authorization AUTHORIZATION HTTP_AUTHORIZATION)
    end

    def set_date
      write_header('DATE', Time.now.utc.httpdate)
    end

    def populate_content_md5
      if post_or_put_request?
        calculated_md5 = self.calculated_md5
        write_header('Content-MD5', calculated_md5)
      end
    end

    def calculated_md5
      Digest::MD5.base64digest(body || '')
    end

    def md5_mismatch?
      if post_or_put_request?
        calculated_md5 != content_md5
      else
        false
      end
    end

    def request_uri
      @request.path
    end

  protected

    def headers
      @request
    end

    def write_header(name, value)
      headers[name] = value
    end

    def read_header(name)
      headers[name]
    end

    def body
      @request.body
    end

    POST_OR_PUT = %w( POST PUT )
    def post_or_put_request?
      POST_OR_PUT.include?(method)
    end

    def method
      @request.method.to_s.upcase
    end

  private

    def find_header(keys)
      keys.each do |key|
        value = read_header(key)
        return value if value
      end
      nil
    end
  end

end
