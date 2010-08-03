require 'spec_helper'

describe Yarel::Base do
  class MyModel < Yarel::Base
  end
  
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
  
  context "initialize" do
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