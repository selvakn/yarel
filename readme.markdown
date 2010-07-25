## YAREL ##

Object Relation Mapper for YQL

Example
-------

    require 'yarel'

    Yarel::GeoPlaces.where(:text => "north beach, san francisco").all
    # Generated YQL: "SELECT * FROM geo.places WHERE text = 'north beach, san francisco'"
    # => [{"name"=>"North Beach", "woeid"=>"2460640", ... }]

  
    Yarel::GeoPlaces.select("centroid.latitude, centroid.longitude").where(:text => "north beach, san francisco").all
    # Generated YQL: "SELECT centroid.latitude, centroid.longitude FROM geo.places WHERE text = 'north beach, san francisco'"
    # => [{"centroid"=>{"latitude"=>"37.805939", "longitude"=>"-122.411118"}}]


    Yarel::SearchNews.where(:query => "election").limit(10,2).to_yql
    # => "SELECT * FROM search.news WHERE query = 'election' LIMIT 2 OFFSET 10"
    
    
    sub_query = Yarel::GeoPlaces.select("centroid.latitude, centroid.longitude").where(:text => "north beach, san francisco")
    Yarel::LocalSearch.where("(latitude,longitude)" => sub_query).where(:radius => 1, :query => 'pizza').sort('AverageRating').to_yql
    # => "SELECT * FROM local.search WHERE (latitude,longitude) in ( SELECT centroid.latitude, centroid.longitude FROM geo.places WHERE text = 'north beach, san francisco' ) AND radius = '1' AND query = 'pizza' | sort(field='AverageRating')"
    
    
    
TODO
----
  1) Insetion / Updation / Deletion