# frozen_string_literal: true

require_relative "hanami/minitest"

# Load Rake tasks last, after hanami/minitest is fully loaded, to avoid circular requires.
#
# When you run `rake test` in a Hanami app, the Rakefile will first require all gems in the `:cli`
# Bundler group, via Hanami CLI. If we required rake_tasks inside hanami/minitest.rb, that file
# would still be mid-load when the Rake test runner loads the test files. Since each test file
# requires test_helper.rb, which itself does `require "hanami/minitest"`, this would otherwise
# lead to a circular require warning.
require_relative "hanami/minitest/rake_tasks"
