require_relative 'application'
require_relative 'client'

# PTTool
module PTTool
  class << self
    def application
      @application ||= PTTool::Application.new
    end

    def client
      @client ||= PTTool::Client.get
    end
  end
end
