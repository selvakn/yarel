require 'active_support'
require 'active_model'
require 'net/http'
require 'cgi'
require 'active_support/core_ext/object/try'
# require 'active_support/core_ext/object/'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/class/inheritable_attributes'
require 'tzinfo'
require 'active_support/json/decoding'
require 'yarel/extensions/object_extensions'

module Yarel
  extend ActiveSupport::Autoload
  
  class Exception < StandardError
  end
  
  eager_autoload do
    autoload :Query
    autoload :Table
    autoload :Connection
    autoload :Base
  end
end

Logger = ActiveSupport::BufferedLogger.new(File.open('yarel.log', 'w+')) unless Module.const_defined?("Logger")