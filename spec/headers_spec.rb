require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ApiAuth::Headers" do

  CANONICAL_STRING = "text/plain,e59ff97941044f85df5297e1c302d260,/resource.xml?foo=bar&bar=foo,Mon, 23 Jan 1984 03:29:56 GMT"

  describe "with Net::HTTP" do

    before(:each) do
      @request = Net::HTTP::Put.new("/resource.xml?foo=bar&bar=foo",
        'content-type' => 'text/plain',
        'content-md5' => 'e59ff97941044f85df5297e1c302d260',
        'date' => "Mon, 23 Jan 1984 03:29:56 GMT")
      @headers = ApiAuth::Headers.new(@request)
    end

    it "should generate the proper canonical string" do
      @headers.canonical_string.should == CANONICAL_STRING
    end

    it "should set the authorization header" do
      @headers.sign_header("alpha")
      @headers.authorization_header.should == "alpha"
    end

    it "should set the DATE header if one is not already present" do
      @request = Net::HTTP::Put.new("/resource.xml?foo=bar&bar=foo",
        'content-type' => 'text/plain',
        'content-md5' => 'e59ff97941044f85df5297e1c302d260')
      ApiAuth.sign!(@request, "some access id", "some secret key")
      @request['DATE'].should_not be_nil
    end

    it "should not set the DATE header just by asking for the canonical_string" do
      request = Net::HTTP::Put.new("/resource.xml?foo=bar&bar=foo",
        'content-type' => 'text/plain',
        'content-md5' => 'e59ff97941044f85df5297e1c302d260')
      headers = ApiAuth::Headers.new(request)
      headers.canonical_string
      request['DATE'].should be_nil
    end

    context "md5_mismatch?" do
      it "is false if no md5 header is present" do
        request = Net::HTTP::Put.new("/resource.xml?foo=bar&bar=foo",
        'content-type' => 'text/plain')
        headers = ApiAuth::Headers.new(request)
        headers.md5_mismatch?.should be_false
      end
    end
  end

  describe "with RestClient" do

    before(:each) do
      headers = { 'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
                  'Content-Type' => "text/plain",
                  'Date' => "Mon, 23 Jan 1984 03:29:56 GMT" }
      @request = RestClient::Request.new(:url => "/resource.xml?foo=bar&bar=foo",
        :headers => headers,
        :method => :put)
      @headers = ApiAuth::Headers.new(@request)
    end

    it "should generate the proper canonical string" do
      @headers.canonical_string.should == CANONICAL_STRING
    end

    it "should set the authorization header" do
      @headers.sign_header("alpha")
      @headers.authorization_header.should == "alpha"
    end

    it "should set the DATE header if one is not already present" do
      headers = { 'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
                  'Content-Type' => "text/plain" }
      @request = RestClient::Request.new(:url => "/resource.xml?foo=bar&bar=foo",
        :headers => headers,
        :method => :put)
      ApiAuth.sign!(@request, "some access id", "some secret key")
      @request.headers['DATE'].should_not be_nil
    end

    it "should not set the DATE header just by asking for the canonical_string" do
      headers = { 'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
                  'Content-Type' => "text/plain" }
      request = RestClient::Request.new(:url => "/resource.xml?foo=bar&bar=foo",
        :headers => headers,
        :method => :put)
      headers = ApiAuth::Headers.new(request)
      headers.canonical_string
      request.headers['DATE'].should be_nil
    end
  end

  describe "with Curb" do

    before(:each) do
      headers = { 'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
                  'Content-Type' => "text/plain",
                  'Date' => "Mon, 23 Jan 1984 03:29:56 GMT" }
      @request = Curl::Easy.new("/resource.xml?foo=bar&bar=foo") do |curl|
        curl.headers = headers
      end
      @headers = ApiAuth::Headers.new(@request)
    end

    it "should generate the proper canonical string" do
      @headers.canonical_string.should == CANONICAL_STRING
    end

    it "should set the authorization header" do
      @headers.sign_header("alpha")
      @headers.authorization_header.should == "alpha"
    end

    it "should set the DATE header if one is not already present" do
      headers = { 'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
                  'Content-Type' => "text/plain" }
      @request = Curl::Easy.new("/resource.xml?foo=bar&bar=foo") do |curl|
        curl.headers = headers
      end
      ApiAuth.sign!(@request, "some access id", "some secret key")
      @request.headers['DATE'].should_not be_nil
    end

    it "should not set the DATE header just by asking for the canonical_string" do
      headers = { 'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
                  'Content-Type' => "text/plain" }
      request = Curl::Easy.new("/resource.xml?foo=bar&bar=foo") do |curl|
        curl.headers = headers
      end
      headers = ApiAuth::Headers.new(request)
      headers.canonical_string
      request.headers['DATE'].should be_nil
    end
  end

  describe "with ActionController" do

    before(:each) do
      @request = ActionController::Request.new(
        'PATH_INFO' => '/resource.xml',
        'QUERY_STRING' => 'foo=bar&bar=foo',
        'REQUEST_METHOD' => 'PUT',
        'CONTENT_MD5' => 'e59ff97941044f85df5297e1c302d260',
        'CONTENT_TYPE' => 'text/plain',
        'HTTP_DATE' => 'Mon, 23 Jan 1984 03:29:56 GMT')
      @headers = ApiAuth::Headers.new(@request)
    end

    it "should generate the proper canonical string" do
      @headers.canonical_string.should == CANONICAL_STRING
    end

    it "should set the authorization header" do
      @headers.sign_header("alpha")
      @headers.authorization_header.should == "alpha"
    end

    it "should set the DATE header if one is not already present" do
      @request = ActionController::Request.new(
        'PATH_INFO' => '/resource.xml',
        'QUERY_STRING' => 'foo=bar&bar=foo',
        'REQUEST_METHOD' => 'PUT',
        'CONTENT_MD5' => 'e59ff97941044f85df5297e1c302d260',
        'CONTENT_TYPE' => 'text/plain')
      ApiAuth.sign!(@request, "some access id", "some secret key")
      @request.headers['DATE'].should_not be_nil
    end

    it "should not set the DATE header just by asking for the canonical_string" do
      request = ActionController::Request.new(
        'PATH_INFO' => '/resource.xml',
        'QUERY_STRING' => 'foo=bar&bar=foo',
        'REQUEST_METHOD' => 'PUT',
        'CONTENT_MD5' => 'e59ff97941044f85df5297e1c302d260',
        'CONTENT_TYPE' => 'text/plain')
      headers = ApiAuth::Headers.new(request)
      headers.canonical_string
      request.headers['DATE'].should be_nil
    end
  end

  describe "with Rack::Request" do

    before(:each) do
      headers = { 'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
                  'Content-Type' => "text/plain",
                  'Date' => "Mon, 23 Jan 1984 03:29:56 GMT"
                  }
      @request = Rack::Request.new(Rack::MockRequest.env_for("/resource.xml?foo=bar&bar=foo", :method => :put).merge!(headers))
      @headers = ApiAuth::Headers.new(@request)
    end

    it "should generate the proper canonical string" do
      @headers.canonical_string.should == "text/plain,e59ff97941044f85df5297e1c302d260,http://example.org/resource.xml?foo=bar&bar=foo,Mon, 23 Jan 1984 03:29:56 GMT"
    end

    it "should set the authorization header" do
      @headers.sign_header("alpha")
      @headers.authorization_header.should == "alpha"
    end

    it "should set the DATE header if one is not already present" do
      headers = { 'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
                  'Content-Type' => "text/plain" }
      @request = Rack::Request.new(Rack::MockRequest.env_for("/resource.xml?foo=bar&bar=foo", :method => :put).merge!(headers))
      ApiAuth.sign!(@request, "some access id", "some secret key")
      @request.env['DATE'].should_not be_nil
    end

    it "should not set the DATE header just by asking for the canonical_string" do
      headers = { 'Content-MD5' => "e59ff97941044f85df5297e1c302d260",
                  'Content-Type' => "text/plain" }
      request = Rack::Request.new(Rack::MockRequest.env_for("/resource.xml?foo=bar&bar=foo", :method => :put).merge!(headers))
      headers = ApiAuth::Headers.new(request)
      headers.canonical_string
      request.env['DATE'].should be_nil
    end
  end

  describe "with a subclass of Request" do

    it "should just keep the object as the request and call methods on it" do
      real_request = {'Date' => :timestamp}
      request = ApiAuth::Request.new(real_request)
      headers = nil
      expect {
        headers = ApiAuth::Headers.new(request)
      }.to_not raise_error(ApiAuth::UnknownHTTPRequest)
      headers.timestamp.should be == :timestamp
    end

  end

end
