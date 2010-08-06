module Yarel
  class Connection
    END_POINT_URL = 'http://query.yahooapis.com/v1/public/yql'
    DEFAULT_FORMAT = :json
    
    attr_reader :endpoint, :env, :format
    
    def initialize(opts={})
      @endpoint = opts[:endpoint] || END_POINT_URL
      @env = opts[:env]
      @format = opts[:format] || DEFAULT_FORMAT
    end

    def get(yql)
      params = { :q => yql, :format => self.format }.tap do |h|
        h[:env] = self.env unless self.env.nil?
      end
        
      response = Net::HTTP.post_form(URI.parse(self.endpoint), params)
      ActiveSupport::JSON.decode response.body
    end
  end
end