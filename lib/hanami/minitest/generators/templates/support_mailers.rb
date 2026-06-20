# frozen_string_literal: true

# Reset recorded mail deliveries between tests.
#
# In the test env, mail is delivered via a shared test delivery method, so recorded
# deliveries accumulate across tests. Include this module in any test that sends mail
# to start with a clean slate:
#
#   class Mailers::WelcomeTest < Hanami::Minitest::Test
#     include TestSupport::Mailers
#     # ...
#   end
module TestSupport
  module Mailers
    def setup
      Hanami.app.with_slices.each do |slice|
        next unless slice.key?("mailers.delivery_method")

        slice["mailers.delivery_method"].clear
      end

      super
    end
  end
end
