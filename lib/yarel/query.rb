module Yarel
  class Query
    attr_reader :table, :projections, :result_limit, :conditions, :result_offset, :sort_field
    
    def initialize(connection, table, opts={})
      @connection = connection
      @table = table
      
      @projections = opts[:projections] || ["*"]
      @result_limit = opts[:result_limit]
      @result_offset = opts[:result_offset]
      @sort_field = opts[:sort_field]
      @conditions = opts[:conditions] || []
    end
    
    def to_yql
      "SELECT #{self.projections.join(', ')} FROM #{self.table}".tap do |q|
        q << " LIMIT #{self.result_limit}" unless self.result_limit.nil?
        q << " OFFSET #{self.result_offset}" unless self.result_offset.nil?
        q << " WHERE #{self.conditions.join(' AND ')}" unless self.conditions.empty?
        q << " | sort(field='#{sort_field}')" unless self.sort_field.nil?
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
    
    def sort(sort_field)
      chain(:sort_field => sort_field)
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
        self.class.new(@connection, attributes[:table] || @table,
          { :result_limit => @result_limit,
            :projections => @projections,
            :result_offset => @result_offset,
            :sort_field => @sort_field
          }.merge(attributes)
        )
      end
  end
end