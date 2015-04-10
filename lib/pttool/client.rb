require 'tracker_api'
require_relative 'error'

module PTTool
  # Provides access to the TrackerApi client.
  class Client
    class << self
      def get
        unless ENV['PT_TOKEN']
          @exit_status = 1
          raise Error, 'PT_TOKEN environment variable must be set'
        end
        begin
          TrackerApi::Client.new(token: ENV['PT_TOKEN']).tap(&:me)
        rescue TrackerApi::Error
          raise Error, 'Could not connect to pivotaltracker'
        end
      end
    end
  end
end
