module Yarel
  class Base
    include ActiveModel::AttributeMethods
    include ActiveModel::Conversion
    
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    
    delegate :to_yql, :to => :table
    attr_accessor :count, :errors, :attributes
    
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
      def connection
      end
      
      def query
      end
      
      def table_name
        @table_name ||= self.name.underscore.gsub("_", ".")
      end
      
      def table_name=(name)
        @table_name = name
        @table = nil
      end
      
      def table
        @table ||= Table.new(self.table_name)
      end
      
    end
  end
end