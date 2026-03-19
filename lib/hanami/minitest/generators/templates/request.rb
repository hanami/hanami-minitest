# frozen_string_literal: true

require "test_helper"

class RootTest < Hanami::Minitest::RequestTest
  test "not found" do
    get "/"

    # Generate new action via:
    #   `bundle exec hanami generate action home.index --url=/`
    assert_equal 404, last_response.status
  end
end
