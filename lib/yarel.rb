require 'extensions/object_extensions'

class Yarel
  attr_accessor :table_name, :projections, :conditions, :limit_to
  
  def initialize(table_name)
    @table_name = table_name
    @projections = "*"
    @conditions = []
    @limit_to = :default_limit
  end
  
  def from(table_name)
    modify_clone { self.table_name = table_name }
  end
  
  def project(*field_names)
    modify_clone { self.projections = field_names.join(", ") }
  end
  
  def where(condition)
    new_condition =
    case 
    when condition.kind_of?(Hash)
      condition.map{|key, value| "#{key} = #{value}"} if (Hash)
    when condition.kind_of?(String)
      condition
    when condition.kind_of?(Array)
      send :sprintf, condition[0].gsub("?", "%s"), *condition[1..-1]
    end

    modify_clone { self.conditions << new_condition } 
  end
  
  def limit(num)
    modify_clone { self.limit_to = num.to_i }
  end
  
  def to_yql
    yql = ["SELECT #{projections} FROM #{table_name}"]
    yql << "WHERE #{conditions.join(' AND ')}" unless conditions.empty?
    yql << "LIMIT #{limit_to}" if limit_to != :default_limit
    yql.join " "
  end

  private
  def modify_clone(&block)
    cloned_obj = self.deep_clone
    cloned_obj.instance_eval &block
    cloned_obj
  end
end