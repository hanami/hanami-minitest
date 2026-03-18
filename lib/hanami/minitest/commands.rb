# frozen_string_literal: true

require "shellwords"

module Hanami
  module Minitest
    # @since 2.0.0
    # @api private
    module Commands
      # @since 2.0.0
      # @api private
      class Install < Hanami::CLI::Command
        # @since 2.0.0
        # @api private
        def call(*, **)
          append_gemfile
          append_gitignore
          copy_test_helper
          copy_support_minitest
          copy_support_db
          copy_support_features
          copy_support_operations
          copy_support_requests
          copy_support_rubocop

          generate_request_test
        end

        private

        def append_gemfile
          gemfile_template = Hanami.bundled?("hanami-db") ? "gemfile_db" : "gemfile"

          fs.append(
            fs.expand_path("Gemfile"),
            fs.read(fs.expand_path(fs.join("generators", gemfile_template), __dir__))
          )
        end

        def append_gitignore
          fs.append(
            fs.expand_path(".gitignore"),
            fs.read(fs.expand_path(fs.join("generators", "gitignore"), __dir__))
          )
        end

        def copy_test_helper
          fs.cp(
            fs.expand_path(fs.join("generators", "helper.rb"), __dir__),
            fs.expand_path(fs.join("test", "test_helper.rb"))
          )
        end

        def copy_support_minitest
          fs.cp(
            fs.expand_path(fs.join("generators", "support_minitest.rb"), __dir__),
            fs.expand_path(fs.join("test", "support", "minitest.rb"))
          )
        end

        def copy_support_db
          return unless Hanami.bundled?("hanami-db")

          fs.cp(
            fs.expand_path(fs.join("generators/support_db.rb"), __dir__),
            fs.expand_path(fs.join("test", "support", "db.rb"))
          )

          fs.cp(
            fs.expand_path(fs.join("generators/support_db_cleaning.rb"), __dir__),
            fs.expand_path(fs.join("test", "support", "db", "cleaning.rb"))
          )
        end

        def copy_support_features
          fs.cp(
            fs.expand_path(fs.join("generators", "support_features.rb"), __dir__),
            fs.expand_path(fs.join("test", "support", "features.rb"))
          )
        end

        def copy_support_operations
          fs.cp(
            fs.expand_path(fs.join("generators", "support_operations.rb"), __dir__),
            fs.expand_path(fs.join("test", "support", "operations.rb"))
          )
        end

        def copy_support_requests
          fs.cp(
            fs.expand_path(fs.join("generators", "support_requests.rb"), __dir__),
            fs.expand_path(fs.join("test", "support", "requests.rb"))
          )
        end

        def copy_support_rubocop
          fs.cp(
            fs.expand_path(fs.join("generators", "support_rubocop.yml"), __dir__),
            fs.expand_path(fs.join("test", "support", ".rubocop.yml"))
          )
        end

        def generate_request_test
          fs.cp(
            fs.expand_path(fs.join("generators", "request.rb"), __dir__),
            fs.expand_path(fs.join("test", "requests", "root_test.rb"))
          )
        end
      end

      # @since 2.0.0
      # @api private
      module Generate
        # @since 2.0.0
        # @api private
        class Slice < Hanami::CLI::Command
          # @since 2.0.0
          # @api private
          def call(options = nil, name: nil, **)
            # Support multiple calling conventions for dry-cli cross-version compatibility:
            #
            # - dry-cli 1.3 calls with positional hash: call({name: "foo"})
            # - dry-cli 1.4+: calls with keyword arguments: call(name: "foo")
            #
            # TODO: Remove this with Hanami 2.4 (which will require dry-cli 1.4+).
            if options.is_a?(Hash)
              name = options[:name]
            end

            slice = inflector.underscore(Shellwords.shellescape(name))

            generator = Generators::Slice.new(fs: fs, inflector: inflector)
            generator.call(slice)
          end
        end

        # @since 2.0.0
        # @api private
        class Action < Hanami::CLI::Commands::App::Command
          # @since 2.0.0
          # @api private
          def call(options = nil, name: nil, slice: nil, skip_tests: false, **)
            # Support multiple calling conventions for dry-cli cross-version compatibility:
            #
            # - dry-cli 1.3 calls with positional hash: call({name: "foo"})
            # - dry-cli 1.4+: calls with keyword arguments: call(name: "foo")
            #
            # TODO: Remove this with Hanami 2.4 (which will require dry-cli 1.4+).
            if options.is_a?(Hash)
              name = options[:name]
              slice = options[:slice]
              skip_tests = options[:skip_tests] || false
            end

            return if skip_tests

            slice = inflector.underscore(Shellwords.shellescape(slice)) if slice
            key = inflector.underscore(Shellwords.shellescape(name))

            namespace = slice ? inflector.camelize(slice) : app.namespace
            base_path = slice ? "test/slices/#{slice}" : "test"

            generator = Generators::Action.new(fs:, inflector:)
            generator.call(key:, namespace:, base_path:)
          end
        end

        # @since 2.1.0
        # @api private
        class Part < Hanami::CLI::Commands::App::Command
          # @since 2.1.0
          # @api private
          def call(options = nil, name: nil, slice: nil, skip_tests: false, **)
            # Support multiple calling conventions for dry-cli cross-version compatibility:
            #
            # - dry-cli 1.3 calls with positional hash: call({name: "foo"})
            # - dry-cli 1.4+: calls with keyword arguments: call(name: "foo")
            #
            # TODO: Remove this with Hanami 2.4 (which will require dry-cli 1.4+).
            if options.is_a?(Hash)
              name = options[:name]
              slice = options[:slice]
              skip_tests = options[:skip_tests] || false
            end

            return if skip_tests

            slice = inflector.underscore(Shellwords.shellescape(slice)) if slice
            name = inflector.underscore(Shellwords.shellescape(name))

            generator = Generators::Part.new(fs: fs, inflector: inflector)
            generator.call(app.namespace, slice, name)
          end
        end
      end
    end
  end
end
