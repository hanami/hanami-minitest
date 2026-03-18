# frozen_string_literal: true

require_relative "features"
require_relative "db/cleaning"

module TestSupport
  module DB
    def self.included(mod)
      mod.include DB::Cleaning
    end

    # Add helper methods to be used by DB tests here.
  end
end

class FeatureTest
  include TestSupport::DB
end
