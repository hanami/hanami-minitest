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
    # @api private
    def self.gem_loader
      @gem_loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "hanami-minitest"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/hanami-minitest.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/hanami-minitest.rb",
          "#{root}/hanami/minitest/{rake_tasks,version}.rb",
          "#{root}/hanami/minitest/generators/templates"
        )
      end
    end

    gem_loader.setup
    require_relative "minitest/version"

    if Hanami::CLI.within_hanami_app?
      require_relative "minitest/commands"
      require_relative "minitest/generators/action"
      require_relative "minitest/generators/mailer"
      require_relative "minitest/generators/operation"
      require_relative "minitest/generators/part"
      require_relative "minitest/generators/slice"

      Hanami::CLI.before "install", Commands::Install
      Hanami::CLI.after "generate slice", Commands::Generate::Slice

      if Hanami.bundled?("dry-operation")
        Hanami::CLI.after "generate operation", Commands::Generate::Operation
        Hanami::CLI.option "generate operation", :skip_tests,
          required: false, type: :flag, default: false, desc: "Skip test generation"
      end

      if Hanami.bundled?("hanami-action")
        Hanami::CLI.after "generate action", Commands::Generate::Action
        Hanami::CLI.option "generate action", :skip_tests,
          required: false, type: :flag, default: false, desc: "Skip test generation"
      end

      if Hanami.bundled?("hanami-view")
        Hanami::CLI.after "generate part", Commands::Generate::Part
        Hanami::CLI.option "generate part", :skip_tests,
          required: false, type: :flag, default: false, desc: "Skip test generation"
      end

      if Hanami.bundled?("hanami-mailer")
        Hanami::CLI.after "generate mailer", Commands::Generate::Mailer
        Hanami::CLI.option "generate mailer", :skip_tests,
          required: false, type: :flag, default: false, desc: "Skip test generation"
      end
    end
  end
end
