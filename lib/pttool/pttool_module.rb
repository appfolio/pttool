require_relative 'application'

module PTTool
  class << self
    def application
      @application ||= PTTool::Application.new
    end
  end
end
