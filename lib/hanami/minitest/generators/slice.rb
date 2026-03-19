# frozen_string_literal: true

require "hanami/cli/ruby_file_generator"

module Hanami
  module Minitest
    module Generators
      # @since 2.0.0
      # @api private
      class Slice
        # @since 2.0.0
        # @api private
        def initialize(fs:, inflector:)
          @fs = fs
          @inflector = inflector
        end

        # @since 2.0.0
        # @api private
        def call(slice)
          camelized_slice_name = inflector.camelize(slice)

          fs.write(
            "test/slices/#{slice}/action_test.rb",
            Hanami::CLI::RubyFileGenerator.class(
              "ActionTest",
              parent_class_name: "Hanami::Minitest::Test",
              modules: [camelized_slice_name],
              header: ["# frozen_string_literal: true", "", 'require "test_helper"'],
              body: [
                "test \"pending\" do",
                "  skip \"Add tests for #{camelized_slice_name} actions\"",
                "end"
              ]
            )
          )

          fs.write("test/slices/#{slice}/actions/.keep", "")
        end

        private

        attr_reader :fs, :inflector
      end
    end
  end
end
