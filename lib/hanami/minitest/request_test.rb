# frozen_string_literal: true

require "rack/test"
require_relative "test"

module Hanami
  module Minitest
    # Base test class for request tests in Hanami applications.
    #
    # Includes Rack::Test::Methods for making HTTP requests to the application.
    #
    # @since 2.0.0
    # @api public
    class RequestTest < Test
      include Rack::Test::Methods

      # Defines the app for Rack::Test requests.
      #
      # @return [Hanami::Application] the Hanami application
      # @since 2.0.0
      # @api public
      def app
        Hanami.app
      end
    end
  end
end
