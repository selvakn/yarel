require 'spec_helper'

describe "yarel" do
  before(:each) do
    @table_name = "answers.getbycategory"
    @yarel_table = Yarel::Table.new(@table_name)
  end

  it "should be chainable" do
    @yarel_table.from("answers.new_table").should be_kind_of(Yarel::Table)
  end

  describe "return the yql" do
    it "should be constructed taking the table name" do
      yarel_table = Yarel::Table.new("ns.table_name").to_yql.should == "SELECT * FROM ns.table_name"
    end

    it "for from" do
      @yarel_table.from("answers.new_table").to_yql.should == "SELECT * FROM answers.new_table"
    end

    it "for the latest from" do
      @yarel_table.from("answers.new_table").from("answers.new_new_table").to_yql.should == "SELECT * FROM answers.new_new_table"
    end

    it "for project" do
      @yarel_table.project(:this_column).to_yql.should == "SELECT this_column FROM answers.getbycategory"
      @yarel_table.project(:this_column, :that_column).to_yql.should == "SELECT this_column, that_column FROM answers.getbycategory"
    end

    it "for limit" do
      @yarel_table.limit(10).to_yql.should == "SELECT * FROM answers.getbycategory LIMIT 10"
    end

    it "for limit should not mutate" do
      q1 = @yarel_table.limit(10)
      q2 = @yarel_table.limit(5)
      q1.to_yql.should == "SELECT * FROM answers.getbycategory LIMIT 10"
      q2.to_yql.should == "SELECT * FROM answers.getbycategory LIMIT 5"
    end

    it "for offset along with limit" do
      @yarel_table.limit(10, 20).to_yql.should == "SELECT * FROM answers.getbycategory LIMIT 20 OFFSET 10"
    end

    describe "where" do
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
    
    it "for sort" do
      @yarel_table.sort('Rating.AverageRating').to_s.should == "SELECT * FROM answers.getbycategory | sort(field='Rating.AverageRating')"
    end
  end
end


describe "yarel module" do
  it "should construct table object" do
    Yarel::GeoLocation.should be_kind_of Yarel::Table
  end
end