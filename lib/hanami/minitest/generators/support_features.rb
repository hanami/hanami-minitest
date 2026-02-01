# frozen_string_literal: true

require "capybara/minitest"

class FeatureTest < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def teardown
    super
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

Capybara.app = Hanami.app
