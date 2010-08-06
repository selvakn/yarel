require 'spec_helper'

describe Yarel::Query do
  context "#table" do
    it "should accept a table name" do
      Yarel::Query.new("the.table").table.should == "the.table"
    end
  end

  context "#from" do
    it "should be chainable" do
      Yarel::Query.new(nil).from("answers.new_table").tap do |query|
        query.should be_kind_of(Yarel::Query)
        query.table.should == "answers.new_table"
      end
    end
    
    it "should be incorporated into the generated YQL" do
      Yarel::Query.new("old.table").from("new.table").to_yql.should == "SELECT * FROM new.table"
    end
    
    it "should incorporate successive calls" do
      Yarel::Query.new("old.table").from("new.table").from("newest.table").to_yql.should == "SELECT * FROM newest.table"
    end
  end
  
  context "#projections" do
    it "should be * by default" do
      Yarel::Query.new("some.table").projections.should == ["*"]
    end
    
    it "should be initializable through the constructor" do
      Yarel::Query.new("some.table", :projections => ["foo", "bar"]).projections.should == ["foo", "bar"]
    end
  end
  
  context "#project" do
    it "should be chainable" do
      Yarel::Query.new("some.table").project("foo", "bar").tap do |query|
        query.should be_kind_of(Yarel::Query)
        query.projections.should == ["foo", "bar"]
      end
    end
    
    it "should convert the given arguments to strings" do
      Yarel::Query.new("some.table").project(:foo).projections.should == ["foo"]
    end
    
    it "should be incorporated into the generated YQL for a single column" do
      Yarel::Query.new("some.table").tap do |query|
        query.project(:this_column).to_yql.should == "SELECT this_column FROM some.table"
        query.project(:this_column, :that_column).to_yql.should == "SELECT this_column, that_column FROM some.table"
      end
    end
  end
  
  context "#result_limit (reader)" do
    it "should be nil by default" do
      Yarel::Query.new("some.table").result_limit.should be_nil
    end
    
    it "should be initializable through the constructor" do
      Yarel::Query.new("some.table", :result_limit => 10).result_limit.should == 10
    end
  end
  
  context "#limit (writer)" do
    it "should be chainable" do
      Yarel::Query.new("some.table").limit(10).tap do |query|
        query.should be_kind_of(Yarel::Query)
        query.result_limit.should == 10
      end
    end
    
    it "should not mutate a pre-existing object" do
      Yarel::Query.new("some.table").tap do |query|
        query.limit(5).result_limit.should == 5
        query.limit(10).result_limit.should == 10
      end
    end
    
    it "should be incorporated into the generated YQL" do
      Yarel::Query.new("some.table").limit(10).to_yql.should == "SELECT * FROM some.table LIMIT 10"
    end
    
    it "should take an optional second argument for specifying the offset" do
      Yarel::Query.new("some.table").limit(5, 15).tap do |query|
        query.result_limit.should == 5
        query.result_offset.should == 15
      end
    end
    
    it "should incorporate offset into the generated YQL" do
      Yarel::Query.new("some.table").limit(5, 15).to_yql.should == "SELECT * FROM some.table LIMIT 5 OFFSET 15"
    end
  end
  
  context "#conditions" do
    it "should be empty by default" do
      Yarel::Query.new("some.table").conditions.should be_empty
    end
    
    it "should be initializable through the constructor" do
      Yarel::Query.new("some.table", :conditions => ["this_column = '5'"]).conditions.should == ["this_column = '5'"]
    end
  end
  
  context "#where" do
    it "should accept a hash of a single parameter" do
      Yarel::Query.new("some.table").where(:this_column => 5).conditions.should == ["this_column = '5'"]
    end
    
    it "should accept a hash of multiple parameters" do
      Yarel::Query.new("some.table").
        where(:this_column => 5, :that_column => 10).conditions.should == ["this_column = '5'", "that_column = '10'"]
    end
    
    it "should allow you to chain multiple conditions" do
      Yarel::Query.new("some.table").
        where(:this_column => 5).
        where(:that_column => 6).conditions.should == ["this_column = '5'", "that_column = '6'"]
    end
    
    it "should accept a string of parameters" do
      Yarel::Query.new("some.table").where("this_column = '5'").conditions.should == ["this_column = '5'"]
    end
    
    it "should accept an array of parameters and interpolate them appropriately" do
      Yarel::Query.new("some.table").
        where(["this_column = ? AND that_column = ?", 5, 10]).conditions.should == ["this_column = '5' AND that_column = '10'"]
    end
    
    it "should add a single given condition to the generated YQL" do
      Yarel::Query.new("some.table").
        where(:this_column => 5).to_yql.should == "SELECT * FROM some.table WHERE this_column = '5'"
    end
    
    it "should add multiple given conditions to the generated YQL" do
      Yarel::Query.new("some.table").
        where(:this_column => 5).
        where("that_column = '10'").to_yql.should == "SELECT * FROM some.table WHERE this_column = '5' AND that_column = '10'"
    end
    
    it "should handle subqueries" do
      Yarel::Query.new("some.table").where(:this_column => Yarel::Query.new("sub_table").project("sub_table_column")).to_yql.should ==
        "SELECT * FROM some.table WHERE this_column IN (SELECT sub_table_column FROM sub_table)"
    end
  end
  
  context "#sort" do
    it "should add the given sort field to the query" do
      Yarel::Query.new("some.table").sort("Rating.AverageRating").sort_field.should == "Rating.AverageRating"
    end
    
    it "should be incorporated into the generated YQL" do
      Yarel::Query.new("some.table").
        sort("Rating.AverageRating").to_yql.should == "SELECT * FROM some.table | sort(field='Rating.AverageRating')"
    end
  end
end