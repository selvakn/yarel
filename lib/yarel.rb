require 'active_support'
require 'active_model'
require 'net/http'
require 'cgi'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/class/attribute_accessors'

module Yarel
  extend ActiveSupport::Autoload
  eager_autoload do
    autoload :Table
    autoload :Connection
    # autoload :Base
  end
  
  def Yarel.const_missing(const_name)
    yql_table_name = const_name.to_s.underscore.gsub("_", ".")
    const_set const_name, Table.new(yql_table_name)
  end  
end
require 'yarel/extensions/object_extensions'
