module Yarel
  class Query
    attr_reader :table, :projections, :result_limit
    
    def initialize(table, opts={})
      @table = table
      @projections = opts[:projections] || ["*"]
      @result_limit = opts[:result_limit]
    end
    
    def to_yql
      "SELECT #{self.projections.join(', ')} FROM #{self.table}".tap do |query|
        query << " LIMIT #{self.result_limit}" unless self.result_limit.nil?
      end
    end
    
    def from(table)
      chain(:table => table)
    end
    
    def project(*attributes)
      chain(:projections => attributes.map(&:to_s))
    end
    
    def limit(result_limit)
      chain(:result_limit => result_limit)
    end
    
    private
    
      def chain(attributes={})
        self.class.new(
          attributes[:table] || @table, 
          { :result_limit => @result_limit,
            :projections => @projections
          }.merge(attributes)
        )
      end
  end
end