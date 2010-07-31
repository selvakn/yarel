require 'spec_helper'

describe "Yarel::Base" do
  class MyModel
    include Yarel::Base
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
end