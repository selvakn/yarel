require 'rubygems'
require 'rspec'
require 'yarel'
require 'test/unit/assertions'
require 'active_model/lint'
require 'ostruct'

module MockConnectionHelpers
  def error_json(desired_message)
    "{'error': {'description': '#{desired_message}'}}"
  end
  
  def error_hash(desired_message)
    ActiveSupport::JSON.decode(error_json(desired_message))
  end
  
  def response_json(input_hashes)
    "{'query':
       {'results': 
         [ #{input_hashes.map(&:to_json).join(', ')} ]
       } 
    }"
  end
  
  def response_hash(input_hashes)
    ActiveSupport::JSON.decode(response_json(input_hashes))
  end
end

RSpec.configure do |c|
  c.include MockConnectionHelpers
end