# frozen_string_literal: true

require "hanami/cli/generators/app/ruby_class_file"
require "hanami/cli/ruby_file_generator"

module Hanami
  module Minitest
    module Generators
      class Operation
        def initialize(fs:, inflector:)
          @fs = fs
          @inflector = inflector
        end

        def call(key:, namespace:, base_path:)
          ruby_class_file = operation_ruby_class_file(key: key, namespace: namespace, base_path: base_path)
          test_file_path = ruby_class_file.path.gsub(/\.rb$/, "_test.rb")
          operation_class_name = ruby_class_file.fully_qualified_name

          fs.write(test_file_path, test_content(operation_class_name))
        end

        private

        attr_reader :fs, :inflector

        def operation_ruby_class_file(key:, namespace:, base_path:)
          Hanami::CLI::Generators::App::RubyClassFile.new(
            fs: fs,
            inflector: inflector,
            namespace: namespace,
            key: inflector.underscore(key),
            base_path: base_path
          )
        end

        def test_content(class_name)
          Hanami::CLI::RubyFileGenerator.class(
            "#{class_name}Test",
            header: ["# frozen_string_literal: true", "", 'require "test_helper"'],
            parent_class_name: "Hanami::Minitest::Test",
            body: <<~RUBY.lines(chomp: true)
              # Use `Success` and `Failure` (from test/support/operations.rb) to assert on an operation's
              # wrapped value:
              #
              # assert_equal Success(thing), result

              test "succeeds" do
                skip "Add assertions for your operation"

                result = #{class_name}.new.call

                assert_predicate result, :success?
              end
            RUBY
          )
        end
      end
    end
  end
end
