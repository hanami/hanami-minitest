# frozen_string_literal: true

require "rack/test"

class RequestTest < Minitest::Test
  include Rack::Test::Methods

  # Defines the app for Rack::Test requests.
  def app
    Hanami.app
  end
end
