# frozen_string_literal: true

require "capybara/minitest"
require_relative "test"

module Hanami
  module Minitest
    # Base test class for feature tests in Hanami applications.
    #
    # Includes Capybara DSL and assertions for browser-based integration testing.
    #
    # @since 2.0.0
    # @api public
    class FeatureTest < Test
      include Capybara::DSL
      include Capybara::Minitest::Assertions

      Capybara.app = Hanami.app

      # Resets Capybara sessions after each test.
      #
      # @since 2.0.0
      # @api public
      def teardown
        super
        Capybara.reset_sessions!
        Capybara.use_default_driver
      end
    end
  end
end
