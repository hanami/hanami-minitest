# frozen_string_literal: true

require "hanami/cli/ruby_file_generator"

module Hanami
  module Minitest
    module Generators
      # @since 2.1.0
      # @api private
      class Part
        # @since 2.1.0
        # @api private
        def initialize(fs:, inflector:)
          @fs = fs
          @inflector = inflector
        end

        # @since 2.1.0
        # @api private
        def call(app, slice, name)
          camelized_app_name = inflector.camelize(app)
          camelized_slice_name = slice ? inflector.camelize(slice) : nil
          camelized_name = inflector.camelize(name)
          underscored_name = inflector.underscore(name)

          if slice
            generate_for_slice(slice, camelized_app_name, camelized_slice_name, camelized_name, underscored_name)
          else
            generate_for_app(camelized_app_name, camelized_name, underscored_name)
          end
        end

        private

        # @since 2.1.0
        # @api private
        attr_reader :fs, :inflector

        # @since 2.1.0
        # @api private
        def generate_for_slice(slice, camelized_app_name, camelized_slice_name, camelized_name, underscored_name)
          generate_base_part_for_app(camelized_app_name)
          generate_base_part_for_slice(slice, camelized_slice_name)

          fs.write(
            "test/slices/#{slice}/views/parts/#{underscored_name}_test.rb",
            part_test_content(camelized_slice_name, camelized_name)
          )
        end

        # @since 2.1.0
        # @api private
        def generate_for_app(camelized_app_name, camelized_name, underscored_name)
          generate_base_part_for_app(camelized_app_name)

          fs.write(
            "test/views/parts/#{underscored_name}_test.rb",
            part_test_content(camelized_app_name, camelized_name)
          )
        end

        # @since 2.1.0
        # @api private
        def generate_base_part_for_app(camelized_app_name)
          path = fs.join("test", "views", "part_test.rb")
          return if fs.exist?(path)

          fs.write(path, base_part_test_content(camelized_app_name))
        end

        # @since 2.1.0
        # @api private
        def generate_base_part_for_slice(slice, camelized_slice_name)
          path = "test/slices/#{slice}/views/part_test.rb"
          return if fs.exist?(path)

          fs.write(path, base_part_test_content(camelized_slice_name))
        end

        # @since 2.1.0
        # @api private
        def base_part_test_content(camelized_namespace)
          Hanami::CLI::RubyFileGenerator.class(
            "PartTest",
            parent_class_name: "Hanami::Minitest::Test",
            header: ["# frozen_string_literal: true", "", 'require "test_helper"'],
            body: [
              "def setup",
              "  @value = Object.new",
              "  @subject = #{camelized_namespace}::Views::Part.new(value: @value)",
              "end",
              "",
              "def test_works",
              "  assert_kind_of #{camelized_namespace}::Views::Part, @subject",
              "end"
            ]
          )
        end

        # @since 2.1.0
        # @api private
        def part_test_content(camelized_namespace, camelized_name)
          Hanami::CLI::RubyFileGenerator.class(
            "#{camelized_name}Test",
            parent_class_name: "Hanami::Minitest::Test",
            header: ["# frozen_string_literal: true", "", 'require "test_helper"'],
            body: [
              "def setup",
              "  @value = Object.new",
              "  @subject = #{camelized_namespace}::Views::Parts::#{camelized_name}.new(value: @value)",
              "end",
              "",
              "def test_works",
              "  assert_kind_of #{camelized_namespace}::Views::Parts::#{camelized_name}, @subject",
              "end"
            ]
          )
        end
      end
    end
  end
end
