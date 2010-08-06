require 'spec_helper'

describe Yarel::Connection do
  
  it "should have a URL endpoint that defaults to Yahoo" do
    Yarel::Connection.new.endpoint.should == Yarel::Connection::END_POINT_URL
  end
  
  it "should allow you to set a custom endpoint" do
    Yarel::Connection.new(:endpoint => "http://some.url").endpoint.should == "http://some.url"
  end
  
  it "should have not have an env by default" do
    Yarel::Connection.new.env.should be_nil
  end
  
  it "should allow you to set a custom env" do
    Yarel::Connection.new(:env => "http://some.url/my.env").env.should == "http://some.url/my.env"
  end
  
  it "should have a format that defaults to JSON" do
    Yarel::Connection.new.format.should == :json
  end
  
  it "should allow you to set a custom format" do
    Yarel::Connection.new(:format => :xml).format.should == :xml
  end
  
  context "#get" do
    it "should post the given query to the correct endpoint" do
      Net::HTTP.should_receive(:post_form).with(
        URI.parse(Yarel::Connection::END_POINT_URL), {:q => "a query", :format => :json}
      ).and_return stub(:body => "")
      
      Yarel::Connection.new.get("a query")
    end
    
    it "should use custom formats and endpoints and envs" do
      Net::HTTP.should_receive(:post_form).with(
        URI.parse("http://some.url"), {:q => "a query", :format => :xml, :env => "http://some.url/my.env"}
      ).and_return stub(:body => "")
      
      Yarel::Connection.new(:format => :xml, :env => "http://some.url/my.env", :endpoint => "http://some.url").get("a query")
    end
  end
  
end