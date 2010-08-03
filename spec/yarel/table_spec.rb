require 'spec_helper'

describe Yarel::Table do
  it "should have a table name" do
    Yarel::Table.new("some.table").table_name.should == "some.table"
  end
end