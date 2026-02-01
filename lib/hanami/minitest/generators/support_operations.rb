# frozen_string_literal: true

require "dry/monads"

module Minitest
  class Test
    # Provide `Success` and `Failure` for testing operation results.
    include Dry::Monads[:result]
  end
end
