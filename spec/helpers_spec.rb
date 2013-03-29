require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ApiAuth::Helpers" do

  it "should strip the new line character on a Base64 encoding" do
    ApiAuth.b64_encode("some string").should_not match(/\n/)
  end

end
