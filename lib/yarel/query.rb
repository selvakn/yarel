module Yarel
  class Query
    attr_reader :table, :projections, :result_limit, :conditions, :result_offset
    
    def initialize(table, opts={})
      @table = table
      @projections = opts[:projections] || ["*"]
      @result_limit = opts[:result_limit]
      @result_offset = opts[:result_offset]
      @conditions = opts[:conditions] || []
    end
    
    def to_yql
      "SELECT #{self.projections.join(', ')} FROM #{self.table}".tap do |query|
        query << " LIMIT #{self.result_limit}" unless self.result_limit.nil?
        query << " OFFSET #{self.result_offset}" unless self.result_offset.nil?
        query << " WHERE #{self.conditions.join(' AND ')}" unless self.conditions.empty?
      end
    end
    
    def from(table)
      chain(:table => table)
    end
    
    def project(*attributes)
      chain(:projections => attributes.map(&:to_s))
    end
    
    def limit(result_limit, result_offset=nil)
      chain(:result_limit => result_limit, :result_offset => result_offset)
    end
    
    def where(condition)
      condition_list = case condition
      when String
        [ condition ]
      when Hash
        condition.map do |key, value|
          case value
          when Yarel::Query
            "#{key} IN (#{value.to_yql})"
          else
            "#{key} = '#{value}'"
          end
        end
      when Array
        [ condition.first.gsub("?", "'%s'") % condition[1..-1] ]
      end
      
      chain(:conditions => self.conditions + condition_list)
    end
    
    private
    
      def chain(attributes={})
        self.class.new(
          attributes[:table] || @table, 
          { :result_limit => @result_limit,
            :projections => @projections,
            :result_offset => @result_offset
          }.merge(attributes)
        )
      end
  end
end