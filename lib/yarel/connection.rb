module Yarel
  class Connection
    END_POINT_URL = 'http://query.yahooapis.com/v1/public/yql'

    def self.get(yql)
      response = Net::HTTP.post_form(URI.parse(END_POINT_URL), { :q => yql, :format => :json })
      ActiveSupport::JSON.decode response.body
    end
  end
end