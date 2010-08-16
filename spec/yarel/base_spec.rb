require 'spec_helper'

describe Yarel::Base do
  class MyModel < Yarel::Base
  end
  
  context ".table_name" do
    before :each do
      MyModel.table_name = nil
    end
  
    it "should set the table name" do
      MyModel.table_name.should == "my.model"
    end
  
    it "should allow you to override the table name" do
      MyModel.table_name = "custom.tablename"
      MyModel.table_name.should == "custom.tablename"
    end
  end
  
  context ".env", :pending => true do
    it "should add the specified env to the end of the query"
  end
  
  context "#initialize" do
    it "should make the given attributes accessible" do
      MyModel.new(:foo => "bar").attributes["foo"].should == "bar"
    end
  
    it "should make the given attributes available as getters on initialize" do
      MyModel.new(:foo => "bar").foo.should == "bar"
    end
  
    it "should make the given attributes available as setters that update the attributes hash" do
      MyModel.new(:foo => "bar").tap do |o|
        o.foo = "baz"
        o.foo.should == "baz"
        o.attributes["foo"].should == "baz"
      end
    end
  
    it "should not build getters for keys that aren't passed in initialize" do
      lambda { MyModel.new.foo }.should raise_error(NoMethodError)
    end
  end
  
  context ".connection" do
    it "should be an instance of Yarel::Connection" do
      MyModel.connection.should be_instance_of(Yarel::Connection)
    end
  end
  
  context "query delegation" do
    Yarel::Base::QUERY_METHODS.each do |method|
      it "should delegate '#{method}' to a new instance of Yarel::Query" do
        mock_query = double('query')
        mock_query.should_receive(method)
        Yarel::Query.should_receive(:new).and_return mock_query
        MyModel.send(method)
      end
    end
  end
  
  describe "ActiveModel Lint tests" do
    include Test::Unit::Assertions
    include ActiveModel::Lint::Tests

    ActiveModel::Lint::Tests.public_instance_methods.map{|m| m.to_s}.grep(/^test/).each do |m|
      example m.gsub('_',' ') do
        send m
      end
    end

    def model
      MyModel.new
    end
  end
end