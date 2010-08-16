module Yarel
  class Base
    include ActiveModel::AttributeMethods
    include ActiveModel::Conversion
    
    extend ActiveModel::Naming
    extend ActiveModel::Translation

    attr_accessor :count, :errors, :attributes
    
    QUERY_METHODS = [:from, :project, :limit, :sort, :where, :all]
    
    def initialize(attributes={})
      @attributes = attributes.stringify_keys
      
      (class << self; self; end).tap do |eigenclass|
        @attributes.keys.each do |attribute_name|
          eigenclass.module_eval <<-RUBY, __FILE__, __LINE__
            def #{attribute_name}
              @attributes['#{attribute_name}']
            end
            
            def #{attribute_name}=(value)
              @attributes['#{attribute_name}'] = value
            end
          RUBY
        end
        eigenclass.define_attribute_methods @attributes.keys
      end
    end
    
    def errors
      require 'ostruct'
      OpenStruct.new(:[] => [], :full_messages => [])
    end
    
    def valid?
      true
    end
    
    def persisted?
      false
    end
    
    class << self
      Yarel::Base::QUERY_METHODS.each { |method| delegate method, :to => :new_query }
      
      def connection
        @connection ||= Yarel::Connection.new
      end
      
      def table_name
        @table_name ||= self.name.underscore.gsub("_", ".")
      end
      
      def table_name=(name)
        @table_name = name
      end
      
      def get(yql)
        connection.get(yql)
      end
      
      private
      
        def new_query
          Yarel::Query.new(self, self.table_name)
        end
    end
  end
end