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
  
    it "should have a table object with the same table name" do
      old_table = MyModel.table
      MyModel.table.table_name.should == "my.model"
    
      MyModel.table_name = "custom.tablename"
      MyModel.table.should_not == old_table
      MyModel.table.table_name.should == "custom.tablename"
    end
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
  
  context ".all" do
    it "should raise exception back if response has errors" do
      Yarel::Connection.should_receive(:get).and_return error_hash("Cannot service your request, good sir")
      lambda { MyModel.all }.should raise_error(Yarel::Exception, "Cannot service your request, good sir")
    end
    
    it "should be empty if no results are returned" do
      Yarel::Connection.should_receive(:get).and_return response_hash([])
      MyModel.all.should be_empty
    end
    
    it "should instantiate one instance of MyModel if one result is returned" do
      Yarel::Connection.should_receive(:get).and_return response_hash([{:foo => "bar"}])
      MyModel.all.tap do |results|
        results.size.should == 1
        results.first.foo.should == "bar"
      end
    end
    
    it "should instantiate one instance of MyModel for each result returned" do
      Yarel::Connection.should_receive(:get).and_return response_hash(
        [{:foo => "bar"}, {:foo => "qux"}, {:foo => "hrmph"}]
      )
      
      MyModel.all.tap do |results|
        results.size.should == 3
        results[0].foo.should == "bar"
        results[1].foo.should == "qux"
        results[2].foo.should == "hrmph"
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