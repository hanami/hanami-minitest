# frozen_string_literal: true

require "hanami/cli"
require "zeitwerk"

# @see Hanami::Minitest
# @since 2.0.0
module Hanami
  # Minitest and testing support for Hanami applications.
  #
  # @since 2.0.0
  # @api private
  module Minitest
    # @since 2.0.0
    # @api private
    def self.gem_loader
      @gem_loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "hanami-minitest"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/hanami-minitest.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/hanami-minitest.rb",
          "#{root}/hanami/minitest/{rake_tasks,version}.rb"
        )
        loader.inflector.inflect("minitest" => "Minitest")
      end
    end

    gem_loader.setup
    require_relative "minitest/version"
    require_relative "minitest/rake_tasks"

    if Hanami::CLI.within_hanami_app?
      Hanami::CLI.before "install", Commands::Install
      Hanami::CLI.after "generate slice", Commands::Generate::Slice

      if Hanami.bundled?("hanami-controller")
        Hanami::CLI.after "generate action", Commands::Generate::Action
      end

      if Hanami.bundled?("hanami-view")
        Hanami::CLI.after "generate part", Commands::Generate::Part
      end
    end
  end
end
