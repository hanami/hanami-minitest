# frozen_string_literal: true

require_relative "hanami/minitest"

# Require Rake tasks last, after hanami/minitest is fully loaded.
#
# When a Hanami app's Rakefile loads, Hanami CLI requires all gems in the `:cli` Bundler group,
# which is what requires this file. If rake_tasks were required from inside hanami/minitest.rb, that
# file would still be mid-load when the user runs `rake test`, which will load the app's
# test_helper.rb, which itself does a require for "hanami/minitest", triggering a circular require
# warning.
require_relative "hanami/minitest/rake_tasks"
