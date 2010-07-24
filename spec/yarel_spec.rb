require 'spec_helper'

describe "yarel" do
  before(:each) do
    @table_name = "answers.getbycategory"
    @yarel = Yarel.new(@table_name)
  end

  it "should be chainable" do
    @yarel.from("answers.new_table").should be_kind_of(Yarel)
  end

  describe "return the yql" do
    it "should be constructed taking the table name" do
      yarel = Yarel.new("ns.table_name").to_yql.should == "SELECT * FROM ns.table_name"
    end

    it "for from" do
      @yarel.from("answers.new_table").to_yql.should == "SELECT * FROM answers.new_table"
    end

    it "for the latest from" do
      @yarel.from("answers.new_table").from("answers.new_new_table").to_yql.should == "SELECT * FROM answers.new_new_table"
    end

    it "for project" do
      @yarel.project(:this_column).to_yql.should == "SELECT this_column FROM answers.getbycategory"
      @yarel.project(:this_column, :that_column).to_yql.should == "SELECT this_column, that_column FROM answers.getbycategory"
    end

    it "for limit" do
      @yarel.limit(10).to_yql.should == "SELECT * FROM answers.getbycategory LIMIT 10"
    end

    it "for limit should not mutate" do
      q1 = @yarel.limit(10)
      q2 = @yarel.limit(5)
      q1.to_yql.should == "SELECT * FROM answers.getbycategory LIMIT 10"
      q2.to_yql.should == "SELECT * FROM answers.getbycategory LIMIT 5"
    end

    describe "where" do
      it "hash" do
        @yarel.where(:this_column => 5).to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = 5"
      end

      it "string" do
        @yarel.where("this_column = 5").to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = 5"
      end

      it "array interpolation" do
        @yarel.where(["this_column = ?", 5]).to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = 5"
      end

      it "should multiple interpolation" do
        @yarel.where(["this_column = ? AND that_column = ?", 5, 10]).to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = 5 AND that_column = 10"
      end

      it "should be able to call multiple times" do
        @yarel.where(["this_column = ?", 5]).project(:this_column).where(:that_column => 10).to_yql.should == "SELECT this_column FROM answers.getbycategory WHERE this_column = 5 AND that_column = 10"
      end

      it "should not mutate the current object" do
        @yarel.where(["this_column = ?", 5]).to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = 5"
        @yarel.where(["this_column = ? AND that_column = ?", 5, 10]).to_yql.should == "SELECT * FROM answers.getbycategory WHERE this_column = 5 AND that_column = 10"
      end
    end
  end
end
