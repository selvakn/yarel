require 'spec_helper'

describe Yarel::Base do
  raise if defined?(LocalSearch)
  LocalSearch = Yarel::Table.new("local.search")

  it "should create an instance of table" do
    LocalSearch.should be_kind_of Yarel::Table
  end

  describe "all" do
    it "should raise exception back if response has errors" do
      lambda {
        LocalSearch.order('test').all
      }.should raise_error(Yarel::Exception, "Cannot find required keys in where clause;   expecting required keys: (query, longitude, latitude)")
    end

    it "should take the result part alone", :pending => true do
      GeoPlaces = Yarel::Table.new("geo.places")
      GeoPlaces.where(:text => "north beach, san francisco").all.should == [{"name"=>"North Beach", "woeid"=>"2460640", "uri"=>"http://where.yahooapis.com/v1/place/2460640", "boundingBox"=>{"northEast"=>{"latitude"=>"37.808270", "longitude"=>"-122.399467"}, "southWest"=>{"latitude"=>"37.795399", "longitude"=>"-122.418381"}}, "postal"=>{"type"=>"Zip Code", "content"=>"94133"}, "country"=>{"code"=>"US", "type"=>"Country", "content"=>"United States"}, "placeTypeName"=>{"code"=>"22", "content"=>"Suburb"}, "centroid"=>{"latitude"=>"37.805939", "longitude"=>"-122.411118"}, "areaRank"=>"1", "admin1"=>{"code"=>"US-CA", "type"=>"State", "content"=>"California"}, "popRank"=>"0", "locality1"=>{"type"=>"Town", "content"=>"San Francisco"}, "admin2"=>{"code"=>"", "type"=>"County", "content"=>"San Francisco"}, "lang"=>"en-US", "locality2"=>{"type"=>"Suburb", "content"=>"North Beach"}, "admin3"=>nil}]
    end
    
    it "should return mulitple records", :pending => true do
      LocalNewSearch = Yarel::Table.new("local.search")
      
      LocalNewSearch.where(:zip => 94085, :query => 'pizza').limit(2).all.should == [
        {"MapUrl"=>"http://maps.yahoo.com/maps_result?q1=1127+N+Lawrence+Expy+Sunnyvale+CA&gid1=21341983", "Distance"=>"1.28", "Longitude"=>"-121.996017", "City"=>"Sunnyvale", "Url"=>"http://local.yahoo.com/info-21341983-giovannis-pizzeria-sunnyvale", "Title"=>"Giovannis Pizzeria", "Latitude"=>"37.397058", "Phone"=>"(408) 734-4221", "id"=>"21341983", "Categories"=>{"Category"=>[{"id"=>"96926234", "content"=>"Carry Out & Take Out"}, {"id"=>"96926236", "content"=>"Restaurants"}, {"id"=>"96926243", "content"=>"Pizza"}]}, "BusinessUrl"=>"http://giovannisnypizza.com/", "ClickUrl"=>"http://local.yahoo.com/info-21341983-giovannis-pizzeria-sunnyvale", "Rating"=>{"TotalReviews"=>"44", "AverageRating"=>"4", "TotalRatings"=>"44", "LastReviewIntro"=>"this is one of the best pizzas i had..very tasty,crispy..value for the money spent..try it out once", "LastReviewDate"=>"1273837240"}, "Address"=>"1127 N Lawrence Expy", "State"=>"CA", "BusinessClickUrl"=>"http://giovannisnypizza.com/"},
        {"MapUrl"=>"http://maps.yahoo.com/maps_result?q1=1155+Reed+Ave+Sunnyvale+CA&gid1=21332026", "Distance"=>"1.79", "Longitude"=>"-121.997904", "City"=>"Sunnyvale", "Url"=>"http://local.yahoo.com/info-21332026-vitos-famous-pizza-sunnyvale", "Title"=>"Vitos Famous Pizza", "Latitude"=>"37.367029", "Phone"=>"(408) 246-8800", "id"=>"21332026", "Categories"=>{"Category"=>[{"id"=>"96926190", "content"=>"Italian Restaurants"}, {"id"=>"96926234", "content"=>"Carry Out & Take Out"}, {"id"=>"96926236", "content"=>"Restaurants"}, {"id"=>"96926242", "content"=>"Fast Food"}, {"id"=>"96926243", "content"=>"Pizza"}]}, "BusinessUrl"=>"http://vitosfamouspizza.com/", "ClickUrl"=>"http://local.yahoo.com/info-21332026-vitos-famous-pizza-sunnyvale", "Rating"=>{"TotalReviews"=>"16", "AverageRating"=>"4.5", "TotalRatings"=>"16", "LastReviewIntro"=>"As an East Coaster, I am picky about my pizza, and this place is really a great find!", "LastReviewDate"=>"1247669752"}, "Address"=>"1155 Reed Ave", "State"=>"CA", "BusinessClickUrl"=>"http://vitosfamouspizza.com/"}
      ]
    end

    it "should handle empty results" do
      places = Yarel::Table.new("geo.places")
      places.where(:text => "unkown place").all.should == []
    end
  end
end