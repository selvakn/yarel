require 'active_support'
require 'active_model'
require 'net/http'
require 'cgi'
require 'active_support/core_ext/object/try'

module Yarel
  extend ActiveSupport::Autoload
  eager_autoload do
    autoload :Table
    autoload :Connection
  end
end
require 'yarel/extensions/object_extensions'