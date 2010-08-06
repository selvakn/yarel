module Yarel
  class Table
    attr_accessor :table_name, :projections, :conditions, :limit_to, :offset, :sort_columns
    
    def initialize(table_name)
      @table_name = table_name
    end
  end
end
