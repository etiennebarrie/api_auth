module ApiAuth

  module Helpers # :nodoc:

    # Remove the ending new line character added by default
    def b64_encode(string)
      Base64.encode64(string).strip
    end

  end

end
