require 'spec_helper'

describe Yarel::Query do
  def stub_model_class(opts={})
    double('model class', opts).tap do |dbl|
      dbl.stub(:new) { |hash| OpenStruct.new(hash) }
    end
  end
  
  def create_query(opts={})
    Yarel::Query.new(
      opts[:model_class] || stub_model_class,
      opts[:table] || "some.table", 
      opts
    )
  end
  
  after(:each) { @model_class = nil }
  
  context "#table" do
    it "should accept a table name" do
      create_query(:table => "the.table").table.should == "the.table"
    end
  end

  context "#from" do
    it "should be chainable" do
      create_query(:table => nil).from("answers.new_table").tap do |query|
        query.should be_kind_of(Yarel::Query)
        query.table.should == "answers.new_table"
      end
    end
    
    it "should be incorporated into the generated YQL" do
      create_query(:table => "old.table").from("new.table").to_yql.should == "SELECT * FROM new.table"
    end
    
    it "should incorporate successive calls" do
      create_query(:table => "old.table").from("new.table").from("newest.table").to_yql.should == "SELECT * FROM newest.table"
    end
  end
  
  context "#projections" do
    it "should be * by default" do
      create_query.projections.should == ["*"]
    end
    
    it "should be initializable through the constructor" do
      create_query(:projections => ["foo", "bar"]).projections.should == ["foo", "bar"]
    end
  end
  
  context "#project" do
    it "should be chainable" do
      create_query.project("foo", "bar").tap do |query|
        query.should be_kind_of(Yarel::Query)
        query.projections.should == ["foo", "bar"]
      end
    end
    
    it "should convert the given arguments to strings" do
      create_query.project(:foo).projections.should == ["foo"]
    end
    
    it "should be incorporated into the generated YQL for a single column" do
      create_query.tap do |query|
        query.project(:this_column).to_yql.should == "SELECT this_column FROM some.table"
        query.project(:this_column, :that_column).to_yql.should == "SELECT this_column, that_column FROM some.table"
      end
    end
  end
  
  context "#result_limit (reader)" do
    it "should be nil by default" do
      create_query.result_limit.should be_nil
    end
    
    it "should be initializable through the constructor" do
      create_query(:result_limit => 10).result_limit.should == 10
    end
  end
  
  context "#limit (writer)" do
    it "should be chainable" do
      create_query.limit(10).tap do |query|
        query.should be_kind_of(Yarel::Query)
        query.result_limit.should == 10
      end
    end
    
    it "should not mutate a pre-existing object" do
      create_query.tap do |query|
        query.limit(5).result_limit.should == 5
        query.limit(10).result_limit.should == 10
      end
    end
    
    it "should be incorporated into the generated YQL" do
      create_query.limit(10).to_yql.should == "SELECT * FROM some.table LIMIT 10"
    end
    
    it "should take an optional second argument for specifying the offset" do
      create_query.limit(5, 15).tap do |query|
        query.result_limit.should == 5
        query.result_offset.should == 15
      end
    end
    
    it "should incorporate offset into the generated YQL" do
      create_query.limit(5, 15).to_yql.should == "SELECT * FROM some.table LIMIT 5 OFFSET 15"
    end
  end
  
  context "#conditions" do
    it "should be empty by default" do
      create_query.conditions.should be_empty
    end
    
    it "should be initializable through the constructor" do
      create_query(:conditions => ["this_column = '5'"]).conditions.should == ["this_column = '5'"]
    end
  end
  
  context "#where" do
    it "should accept a hash of a single parameter" do
      create_query.where(:this_column => 5).conditions.should == ["this_column = '5'"]
    end
    
    it "should accept a hash of multiple parameters" do
      create_query.
        where(:this_column => 5, :that_column => 10).conditions.should =~ ["this_column = '5'", "that_column = '10'"]
    end
    
    it "should allow you to chain multiple conditions" do
      create_query.
        where(:this_column => 5).
        where(:that_column => 6).conditions.should == ["this_column = '5'", "that_column = '6'"]
    end
    
    it "should accept a string of parameters" do
      create_query.where("this_column = '5'").conditions.should == ["this_column = '5'"]
    end
    
    it "should accept an array of parameters and interpolate them appropriately" do
      create_query.
        where(["this_column = ? AND that_column = ?", 5, 10]).conditions.should == ["this_column = '5' AND that_column = '10'"]
    end
    
    it "should add a single given condition to the generated YQL" do
      create_query.
        where(:this_column => 5).to_yql.should == "SELECT * FROM some.table WHERE this_column = '5'"
    end
    
    it "should add multiple given conditions to the generated YQL" do
      create_query.
        where(:this_column => 5).
        where("that_column = '10'").to_yql.should == "SELECT * FROM some.table WHERE this_column = '5' AND that_column = '10'"
    end
    
    it "should handle subqueries" do
      create_query.where(:this_column => create_query(:table => "sub_table").project("sub_table_column")).to_yql.should ==
        "SELECT * FROM some.table WHERE this_column IN (SELECT sub_table_column FROM sub_table)"
    end
  end
  
  context "#sort" do
    it "should add the given sort field to the query" do
      create_query.sort("Rating.AverageRating").sort_field.should == "Rating.AverageRating"
    end
    
    it "should be incorporated into the generated YQL" do
      create_query.
        sort("Rating.AverageRating").to_yql.should == "SELECT * FROM some.table | sort(field='Rating.AverageRating')"
    end
  end
  
  context "#execute" do
    it "should run the query against the connection of the given model class" do
      model_class = mock(:model_class)
      query = create_query(:model_class => model_class)
      model_class.should_receive(:get).with(query.to_yql)
      query.execute
    end
  end
  
  context "include Enumerable" do
    it "should include the module" do
      Yarel::Query.should include(Enumerable)
    end
    
    it "should delegate #each to #all.each" do
      stub = stub_model_class
      query = create_query(:model_class => stub)
      stub.should_receive(:get).and_return response_hash([])
      query.each {}
    end
  end
  
  context "#all" do
    it "should raise exception back if response has errors" do
      lambda do
        create_query(:model_class => stub_model_class(:get => error_hash("Cannot service your request, good sir"))).all
      end.should raise_error(Yarel::Exception, "Cannot service your request, good sir")
    end
    
    it "should be empty if no results are returned" do
      create_query(:model_class => stub_model_class(:get => response_hash([]))).all.should be_empty
    end
    
    it "should instantiate one instance of MyModel if one result is returned" do
      create_query(:model_class => stub_model_class(:get => response_hash([{:foo => "bar"}]))).all.tap do |results|
        results.size.should == 1
        results.first.foo.should == "bar"
      end
    end
    
    it "should instantiate one instance of MyModel for each result returned" do
      query = create_query(:model_class => stub_model_class(:get => response_hash(
        [{:foo => "bar"}, {:foo => "qux"}, {:foo => "hrmph"}]
      )))
      
      query.all.tap do |results|
        results.size.should == 3
        results[0].foo.should == "bar"
        results[1].foo.should == "qux"
        results[2].foo.should == "hrmph"
      end
    end
  end
end