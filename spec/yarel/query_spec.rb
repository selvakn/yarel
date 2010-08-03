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
  end

  context "#to_yql", :pending => true do
    it "for offset along with limit" do
      @yarel_table.limit(10, 20).to_yql.should == "SELECT * FROM answers.getbycategory LIMIT 20 OFFSET 10"
    end

    describe "#where" do
      it "hash" do
        @yarel_table.where(:this_column => 5).to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = '5'"
      end

      it "string" do
        @yarel_table.where("this_column = '5'").to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = '5'"
      end

      it "array interpolation" do
        @yarel_table.where(["this_column = ?", 'asd']).to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = 'asd'"
      end

      it "should multiple interpolation" do
        @yarel_table.where(["this_column = ? AND that_column = ?", 5, 10]).to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = '5' AND that_column = '10'"
      end

      it "should be able to call multiple times" do
        @yarel_table.where(["this_column = ?", 5]).project(:this_column).where(:that_column => 10).to_yql.should == "SELECT this_column FROM answers.getbycategory WHERE this_column = '5' AND that_column = '10'"
      end

      it "should not mutate the current object" do
        @yarel_table.where(["this_column = ?", 5]).to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = '5'"
        @yarel_table.where(["this_column = ? AND that_column = ?", 5, 10]).to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = '5' AND that_column = '10'"
      end
      
      describe "where with sub queries" do
        it "as a hash" do
          @yarel_table.where(:this_column => Yarel::Table.new(:sub_table).project("sub_table_column")).to_yql.should ==
            "SELECT * FROM answers.getbycategory WHERE this_column in ( SELECT sub_table_column FROM sub_table )"
        end
      end
    end
    
    it "should sort" do
      @yarel_table.sort('Rating.AverageRating').to_s.should == "SELECT * FROM answers.getbycategory | sort(field='Rating.AverageRating')"
    end
  end
end